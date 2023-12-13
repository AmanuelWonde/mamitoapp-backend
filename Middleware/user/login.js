// module imports and configs
const bcrypt = require('bcryptjs');
const JWT = require('jsonwebtoken');

// mysql configurations
const db = require('../../Config/config');

// model imports
const { loggerSchema } = require('../../Models/user');
const { status, responseInstance } = require('../../Models/response');
const documentation = require('../../documentation/statusCodeDocumentation.json');

module.exports = (req, res) => {
    const debugg = require('debug')('login:');
    let p1 = new Promise((resolve, reject) => {
        let { error } = loggerSchema.validate(req.body);
        if (error) reject(new responseInstance(new status(6001, documentation[6001]), error.details[0].message));
        else resolve(req.body);
    });

    const userVerification = (body) => {
        return new Promise((resolve, reject) => {
            const debug = require('debug')('login:userVerification');
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
                        reject(new status(7003, documentation[7003]), 'this is a backend issue');
                    } else {
                        if (result[0][0].status == 1015) {
                            reject(new status(1015, documentation[1015]), 'user not registered');
                        } else {
                            resolve(result[0][0])
                        }
                    }
                })
            })
        })
    }

    const passworValidation = (body) => {
        const debug = require('debug')('login:passwordValidation');
        return new Promise((resolve, reject) => {
            bcrypt.compare(req.body.password, body.password, (error, res) => {
                if (error) {
                    debug(error);
                    reject(new responseInstance(new status(6012, documentation[6012]), error));
                } else {
                    if (res) {
                        delete body.password;
                        resolve(body);
                    } else {
                        reject(new responseInstance(new status(1014, documentation[1014]), 'use a valid password'));
                    }
                }
            })
        })
    }

    const sender = (body) => {
        const auth_token = JWT.sign({
            username: body.username,
            birthdate: body.birthdate,
        }, 'hiruy');
        res.setHeader('auth-token', auth_token).send(new responseInstance(new status(1013, documentation[1013]), body));
    }

    p1
        .then((body) => userVerification(body))
        .then((result) => passworValidation(result))
        .then((result) => sender(result))
        .catch((error) => { res.send(error); debugg(error) });
}