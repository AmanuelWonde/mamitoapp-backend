// mysql configurations
const mysql = require('mysql2');
const dbConfig = require('../../Config/dbConfig');
const db = mysql.createPool(dbConfig);

// model imports
const { status, responseInstance } = require('../../Models/response');
const { newConversation } = require('../../Models/conversation/conversation');

module.exports = (req, res) => {
    const debugg = require('debug')('clearconversation');
    const p1 = new Promise((resolve, reject) => {
        const debug = require('debug')('clearconversation:p1');
        const { error } = newConversation.validate(req.body);
        if (error) {
            debug(error.details);
            reject(new responseInstance(new status(6001, 'invalid json content'), error.details));
        } else {
            resolve(req.body);
        }
    });

    const deleteConversation = (body) => {
        const debug = require('debug')('clearconversation:deleteconversation');
        return new Promise((resolve, reject) => {
            db.getConnection((error, connection) => {
                if (error) {
                    debug(`Error: ${error}`);
                    reject(new responseInstance(new status(6012, 'unable to get pool connection'), 'this is a backend issue'));
                }

                const sql = 'CALL DeleteConversation(?, ?)';
                const values = [body.user1, body.user2];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();

                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(6013, 'unable to continue database operation'), 'this is a backend issue'));
                        return;
                    }
                    debug(result);
                    resolve(result);
                });
            })
        })
    }

    const sender = (result) => {
        res.send(new responseInstance(new status(1003, 'conversation deleted successfully'), 'all things related to that conversaton are deleted, you can create a new conversation with the other user'))
    }

    p1
        .then((body) => deleteConversation(body))
        .then((result) => sender(result))
        .catch(error => { debugg(error); res.send(error) });
}