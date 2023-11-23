// module imports and configs
const bcrypt = require('bcryptjs');
const JWT = require('jsonwebtoken');

// mysql configurations
const mysql = require('mysql2');
const dbConfig = require('../../Config/dbConfig');
const db = mysql.createPool(dbConfig);

// model imports
const { loggerSchema } = require('../../Models/user');
const { status, responseInstance } = require('../../Models/response');
const documentation = require('../../documentation/statusCodeDocumentation.json');

module.exports = (req, res) => {
    const debugg = require('debug')('login:');
    let p1 = new Promise((resolve, reject) => {
        const debug = require('debug')('login:schema');
        const { error } = loggerSchema.validate(req.body);
        if (error) {
            debug(error);
            reject(new responseInstance(new status(6001, documentation[6001]), error.details));
        }
        else {
            resolve(req.body);
        }
    });

    const userVerification = (body) => {
        return new Promise((resolve, reject) => {
            const debug = require('debug')('login:userVerification');
            db.getConnection((error, connection) => {
                if (error) {
                    debug(error);
                    reject(new responseInstance(new responseInstance(new status(7001, 'unable to connect to database'), 'this is a backend issue')));
                } else {

                    const sql = 'CALL GetUserByUsername(?)';
                    const values = [body.username];

                    connection.query(sql, values, (error, result, field) => {
                        if (error) {
                            debug(error);
                            reject(new status(1012, documentation[7003]), 'this is a backend issue');
                        } else {
                            if (result[0][0].status == 1012) {
                                reject(new status(1012, documentation[1012]), 'retry with other username or create a new account');
                            } else {
                                resolve(result[0][0])
                            }
                        }
                    })
                }
            })
        })
    }

    const userValidation = (result) => {
        const debug = require('debug')('login:userValidation');
        return new Promise((resolve, reject) => {
            debug(result.length)
            if (result.username) {
                resolve(result.password);
            }
            else {
                reject(new responseInstance(new status(6004, documentation[6004]), 'try a valid username and password'))
            }
        })
    }

    const passworValidation = (password) => {
        const debug = require('debug')('login:passwordValidation')
        return new Promise((resolve, reject) => {
            bcrypt.compare(req.body.password, password, (error, res) => {
                if (error) {
                    debug(error);
                    reject(new responseInstance(new status(6005, documentation[6005]), 'try a valid password'));
                } else {
                    debug('res: ', res)
                    if (res) {
                        resolve(req.body);
                    } else {
                        reject(new responseInstance(new status(6005, documentation[6005]), 'try a valid password'));
                    }
                }
            })
        })
    }

    const sender = (body) => {
        const auth_token = JWT.sign({
            username: body.username,
            birthdate: body.birthdate,
        }, process.env.jwt);
        res.setHeader('auth-token', auth_token).send(new responseInstance(new status(1001, documentation[1001]), 'successfully logged in'));
    }

    p1
        .then((body) => userVerification(body))
        .then((result) => userValidation(result))
        .then((result) => passworValidation(result))
        .then((result) => sender(result))
        .catch((error) => { res.send(error); debugg(error) });
}