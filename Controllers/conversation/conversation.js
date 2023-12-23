// mysql configurations
const db = require('../../Config/config');

// socket configurations
const { io } = require('../../app');

// component imports
const { status, responseInstance } = require('../../Models/response');
const { updateConversation } = require('../../Models/conversation/conversation');
const documentation = require('../../documentation/statusCodeDocumentation.json');

const p1 = (req) => {
    return new Promise((resolve, reject) => {
        const debug = require('debug')('upcon:p1');
        const { error } = updateConversation.validate(req.body);
        if (error) {
            debug(error.details[0].message);
            reject(new responseInstance(new status(6001, 'invalid json content'), error.details[0].message));
        } else {
            resolve(req.body);
        }
    })
}

const op1 = (body) => {
    const debug = require('debug')('upcon:op1');
    return new Promise((resolve, reject) => {
        db.getConnection((error, connection) => {
            if (error) {
                debug(`Error: ${error}`);
                reject(new responseInstance(new status(7001, documentation[7001]), 'this is backend issue'));
            }

            const sql = 'CALL UpdateConversationStatus(?, ?)';
            const values = [body.id, body.op];

            connection.query(sql, values, (error, result) => {
                connection.release();
                if (error) {
                    debug(`Error: ${error}`);
                    reject(new responseInstance(new status(7002, documentation[7002]), 'this is a backend issue'));
                } else {
                    if (result[0][0].status == 1040) {
                        resolve(new responseInstance(new status(1040), result[0][0]));
                    } else if (result[0][0].status == 1041) {
                        resolve(new responseInstance(new status(1041), result[0][0]));
                    } else if (result[0][0].status == 1042) {
                        resolve(new responseInstance(new status(1042), result[0][0]));
                    }
                }
            });

        });
    })
}

const sender = (result, res) => {
    if (result.status == 1040 || result.status == 1041) {
        res.send(result);
        io.emit(result.content.receiver, result);
    } else {
        res.send(result);
    }
}

module.exports = { p1, sender, op1 }