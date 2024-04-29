// module imports and configs
const bcrypt = require('bcryptjs');
const JWT = require('jsonwebtoken');

// mysql configurations
const db = require('../../Config/config');

// model imports
const { changePassword } = require('../../Models/User');
const { status, responseInstance } = require('../../Models/response');
const documentation = require('../../documentation/statusCodeDocumentation.json');

module.exports = (req, res) => {

    const debug = require('debug')('user:chpd');

    let p1 = new Promise((resolve, reject) => {
        let { error } = changePassword.validate(req.body);
        if (error) reject(new responseInstance(new status(6001, documentation[6001]), error.details[0].message));
        else resolve(req.body);
    });

    const userVerification = (body) => {
        return new Promise((resolve, reject) => {
            db.getConnection((error, connection) => {
                if (error) {
                    debug(`Error: ${error}`);
                    reject(new responseInstance(new status(7001, documentation[7001]), 'this is backend issue'));
                }

                const sql = 'CALL GetUserByUsername(?)';
                const values = [body.username];

                connection.query(sql, values, (error, result, field) => {
                    connection.release();

                    if (error) {
                        debug(error);
                        reject(new responseInstance(new status(7003, documentation[7003]), 'this is a backend issue'));
                    } else {
                        if (result[0][0].status == 1015) {
                            reject(new responseInstance(new status(1015, documentation[1015]), 'user not registered'));
                        } else {
                            resolve(result[0][0])
                        }
                    }
                })
            })
        })
    }

    const passwordValidation = (body) => {
        return new Promise((resolve, reject) => {
            bcrypt.compare(req.body.oldpassword, body.password, (error, res) => {
                if (error) {
                    debug(error);
                    reject(new responseInstance(new status(6012, documentation[6012]), error));
                } else {
                    if (res) {
                        resolve(body);
                    } else {
                        reject(new responseInstance(new status(1014, documentation[1014]), 'use a valid password'));
                    }
                }
            })
        })
    }

    const passwordEncryption = (body) => {
        return new Promise(async (resolve, reject) => {
            bcrypt.genSalt(10, (err, salt) => {
                if (err) {
                    debug(err);
                    reject(new responseInstance(new status(6010, documentation[6010]), 'this is a backend issue'));
                };
                bcrypt.hash(req.body.newpassword, salt, (err, result) => {
                    if (err) {
                        debug(err);
                        reject(new responseInstance(new status(6011, documentation[6011]), 'this is a backend issue'));
                    }
                    resolve(result);
                })
            })
        })
    }

    const store = (encrypted) => {
        return new Promise((resolve, reject) => {

            db.getConnection((error, connection) => {
                if (error) {
                    debug(`Error: ${error}`);
                    reject(new responseInstance(new status(7001, documentation[7001]), 'this is backend issue'));
                }

                const sql = 'CALL UpdatePassword(?, ?)';
                const values = [req.body.username, encrypted];

                connection.query(sql, values, (error, result) => {
                    if (error) {
                        debug(error);
                        reject(new responseInstance(new status(7003, documentation[7003]), 'this is a backend issue'));
                    } else {
                        if (result[0][0].status == 1061) {
                            debug(result);
                            reject(new responseInstance(new status(1061, documentation[1061]), 'user not registered'));
                        } else {
                            resolve(result[0][0])
                        }
                    }
                })
            })

        })
    }

    const sender = () => {
        res.send(new responseInstance(new status(1060), "successfull"))
    }

    p1
        .then((body) => userVerification(body))
        .then((body) => passwordValidation(body))
        .then((body) => passwordEncryption(body))
        .then((result) => store(result))
        .then(() => sender())
        .catch((error) => res.send(error))
}