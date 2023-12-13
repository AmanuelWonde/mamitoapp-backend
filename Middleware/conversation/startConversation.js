// mysql configurations
const db = require('../../Config/config');

// module imports
/* const { io } = require('socket.io-client');
const socket = io('http://localhost:3001'); */

// component imports
const { status, responseInstance } = require('../../Models/response');
const { newConversation } = require('../../Models/conversation/conversation');
const documentation = require('../../documentation/statusCodeDocumentation.json');

module.exports = (req, res) => {
    const debugg = require('debug')('startconversation');
    const p1 = new Promise((resolve, reject) => {
        const debug = require('debug')('startconversation:p1');
        const { error } = newConversation.validate(req.body);
        if (error) {
            debug(error.details[0].message);
            reject(new responseInstance(new status(6001, 'invalid json content'), error.details[0].message));
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
                    reject(new responseInstance(new status(7001, documentation[7001]), 'this is backend issue'));
                }

                const sql = 'CALL InsertConversation(?, ?)';
                const values = [body.user1, body.user2];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();
                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7002, documentation[7002]), 'this is a backend issue'));
                        return;
                    } else {
                        if (result[0][0].status == 1021) {
                            reject(new responseInstance(new status(1021, documentation[1021]), "the coversation with the user is already existed"));
                        } else {
                            resolve(result[0][0]);
                        }
                    }
                });

            });

        })
    }

    const sender = (result) => {
        res.send(new responseInstance(new status(1020, documentation[1020]), result));
        /* socket.emit('new_conversation', 1, 'abelmaireg'); */
    }

    p1
        .then((body) => insertConversation(body))
        .then((result) => sender(result))
        .catch((error) => { debugg(error); res.send(error) });
}