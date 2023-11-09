// module imports and configs
const bcrypt = require('bcryptjs');
const express = require('express');
const router = express.Router();


// mysql configurations
const mysql = require('mysql');
const dbConfig = require('../Config/dbConfig');
const db = mysql.createPool(dbConfig);

// multer configurations imports
const { upload } = require('../Config/multerConfig');

// model imports
const { userSchema } = require('../Models/user');
const { status, responseInstance } = require('../Models/response');

router.post('/signup', (req, res) => {
    const debug = require('debug')('user:signup');

    let p1 = new Promise((resolve, reject) => {
        let { error } = userSchema.validate(req.body);
        if (error) reject(new responseInstance(`Error: Invalid User Details`, error));
        else resolve(req.body);
    });

    function usernameValidation(body) {
        const debug = require('debug')('signup:usernameValdiate');
        return new Promise(async (resolve, reject) => {

            db.getConnection((error, connection) => {
                if (error) {
                    reject(new responseInstance(`Error: unable to connect to database`, error));
                }

                connection.query(`CALL GetUserByUsername(\'${body.username}\')`, (error, result, fields) => {
                    debug('error', error); debug('results', result); debug('fields', fields);
                    if (error) reject(new responseInstance(`Error: unknown issue`, error));
                    if (result[0].length > 0) reject(new responseInstance(`Error`, `${body.username} is unavilable`))
                    resolve(body);
                });
            })
        });
    }

    function passwordEncryption(body) {
        const debug = require('debug')('signup:encrypting');
        return new Promise(async (resolve, reject) => {
            bcrypt.genSalt(10, (err, salt) => {
                if (err) {
                    debug(err);
                    reject(new responseInstance(new status(3010, 'unable to generate salt'), 'this is a backend issue'));
                };
                bcrypt.hash(body.password, salt, (err, result) => {
                    if (err) {
                        debug(err);
                        reject(new responseInstance(new status(3011, 'unable to hash password'), 'this is a backend issue'));
                    }
                    body.password = result;
                    resolve(body);
                })
            })
        })
    }

    function insertData(body) {
        const debug = require('debug')('signup:inserting');
        return new Promise((resolve, reject) => {
            db.getConnection((error, connection) => {
                if (error) {
                    debug(`Error: ${error}`);
                    reject(new responseInstance(new status(3012, 'unable to get pool connection'), 'this is backend issue'));
                }

                connection.query(`CALL InsertUser(
                \'${body.username}\',
                \'${body.sex}\',
                \'${body.phone}\',
                \'${body.email}\',
                \'${body.password}\',
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL
                )`, (error, result, fields) => {
                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(3012, 'unable to save user\'s data to the database'), 'this is backend issue'));
                    }
                    resolve(result);
                })
            })
        })
    }

    function sender(heir) {
        res.send(new responseInstance('passed the test', heir));
    }

    p1
        .then((body) => usernameValidation(body))
        .then((body) => passwordEncryption(body))
        .then((body) => insertData(body))
        .then((result) => sender(result))
        .catch((error) => { res.status(400).send(error); debug(error) });
});

module.exports = { router };