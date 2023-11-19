// database comfigurations
const mysql = require('mysql2');
const dbConfig = require('../../Config/dbConfig');
const db = mysql.createPool(dbConfig);

// module and model imports
const JWT = require('jsonwebtoken');
const { status, responseInstance } = require('../../Models/response');

module.exports = (req, res, next) => {
    const debugg = require('debug')('auth');
    let p1 = new Promise((resolve, reject) => {
        const debug = require('debug')('auth:user');
        const token = req.header('auth-token');
        if (token) {
            resolve(token);
        } else {
            debug('token is needed for authentication');
            reject(new responseInstance(new status(5001, 'token is required'), 'use a token inorder to get services'))
        }
    });

    const tokenAuthentication = (token) => {
        const debug = require('debug')('auth:auth')
        return new Promise((resolve, reject) => {
            try {
                const verification = JWT.verify(token, process.env.jwt);
                resolve(verification);
            } catch (error) {
                debug(error);
                reject(new responseInstance(new status(5002, 'verification failed'), 'use a valid token in order to get services'));
            }
        })
    }

    const verify = (verification) => {
        next();
    }

    p1
        .then((token) => tokenAuthentication(token))
        .then((verification) => verify(verification))
        .catch((error) => { debugg(error); res.send(error) });
}