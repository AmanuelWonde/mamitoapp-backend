// module imports and configs
const bcrypt = require('bcryptjs');
const express = require('express');
const router = express.Router();


// mysql configurations
const mysql = require('mysql');
const dbConfig = require('../Config/dbConfig');
const db = mysql.createPool(dbConfig);

db.getConnection(err => {
    if (err) throw err;
    else console.log('connected to mysql server')
})

// multer configurations imports
const { upload } = require('../Config/multerConfig');

// model imports
const { userSchema } = require('../Models/user');
const { status, responseInstance } = require('../Models/response');

router.post('/signup', (req, res) => {
    const debug = require('debug')('user:signup');

    let p1 = new Promise((resolve, reject) => {
        let { error } = userSchema.validate(req.body);
        if (error) reject(new responseInstance(new status(6001, 'invalid json content'), 'ckeck the properties and the values of the object!'));
        else resolve(req.body);
    });

    function usernameValidation(body) {
        const debug = require('debug')('signup:usernameValdiate');
        return new Promise(async (resolve, reject) => {

            db.getConnection((error, connection) => {
                if (error) {
                    reject(new responseInstance(new status(7001, 'unable to connect to database'), 'this is a backend issue'));
                }

                connection.query(`CALL GetUserByUsername(\'${body.username}\')`, (error, result, fields) => {
                    if (error) {
                        debug('error', error);
                        if (error) reject(new responseInstance(`Error: unknown issue`, error));
                    }
                    if (result[0].length > 0) reject(new responseInstance(new status(6003, 'username is unavailable'), `the username ${body.username} is unavilable, try another`))
                    resolve(body);
                });
            })
        });
    }

    function phoneNumberValidation(body) {
        const debug = require('debug')('signup:phoneNumberValidation');
        return new Promise(async (resolve, reject) => {

            db.getConnection((error, connection) => {
                if (error) {
                    reject(new responseInstance(new status(7001, 'unable to connect to database'), 'this is a backend issue'));
                }

                connection.query(`CALL GetUserByPhone(\'${body.phone}\')`, (error, result, fields) => {
                    if (error) {
                        debug('error', error);
                        reject(new responseInstance(`Error: unknown issue`, error));
                    }
                    if (result[0].length > 0) reject(new responseInstance(new status(6004, 'phone number is registered'), `the phone number ${body.phone} is already registered, change phone number`))
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
                    reject(new responseInstance(new status(6010, 'unable to generate salt'), 'this is a backend issue'));
                };
                bcrypt.hash(body.password, salt, (err, result) => {
                    if (err) {
                        debug(err);
                        reject(new responseInstance(new status(6011, 'unable to hash password'), 'this is a backend issue'));
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
                    reject(new responseInstance(new status(6012, 'unable to get pool connection'), 'this is backend issue'));
                }

                connection.query(`CALL InsertUser(
                \'${body.username}\',
                \'${body.gender}\',
                \'${body.phone}\',
                \'${body.email}\',
                \'${body.password}\',
                ${body.educationalStatus || "NULL"},
                NULL,
                NULL,
                NULL,
                NULL,
                NULL
                )`, (error, result, fields) => {
                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(6013, 'unable to save user\'s data to the database'), 'this is backend issue'));
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
        .then((body) => phoneNumberValidation(body))
        .then((body) => passwordEncryption(body))
        .then((body) => insertData(body))
        .then((result) => sender(result))
        .catch((error) => { res.status(400).send(error); debug(error) });
});

module.exports = { router };