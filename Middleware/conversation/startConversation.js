// mysql configurations
const mysql = require('mysql2');
const dbConfig = require('../../Config/dbConfig');
const db = mysql.createPool(dbConfig);

// module imports
const Joi = require('joi');

// component imports
const { status, responseInstance } = require('../../Models/response');
const { newConversation } = require('../../Models/conversation/conversation');

module.exports = (req, res) => {
    const debugg = require('debug')('startconversation');
    const p1 = new Promise((resolve, reject) => {
        const debug = require('debug')('startconversation:p1');
        const { error } = newConversation.validate(req.body);
        if (error) {
            debug(error.details);
            reject(new responseInstance(new status(6001, 'invalid json content'), error.details));
        } else {
            resolve(req.body);
        }
    });

    const insertConversation = (body) => {
        const debug = require('debug')('startconversation:insertconversation');
        return new Promise((resolve, reject) => {
            db.getConnection((error, connection) => {
                if (error) {
                    debug(`Error: ${error}`);
                    reject(new responseInstance(new status(6012, 'unable to get pool connection'), 'this is a backend issue'));
                }

                const sql = 'CALL InsertConversation(?, ?)';
                const values = [body.user1, body.user2];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();
                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(6013, 'unable to save user\'s data to the database'), 'this is a backend issue'));
                        return;
                    } else {
                        if (result[0][0].status == 7002) {
                            reject(new responseInstance(new status(7002, "conversation already exists"), "conversation already exists"))
                        } else {
                            resolve(result[0][0]);
                        }
                    }
                });

            });

        })
    }

    const sender = (result) => {
        res.send(new responseInstance(new status(1002, 'conversation created successfully'), result));
    }

    p1
        .then((body) => insertConversation(body))
        .then((result) => sender(result))
        .catch((error) => { debugg(error); res.send(error) });
}