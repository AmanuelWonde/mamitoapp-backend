// mysql configurations
const db = require('../../Config/dbConfig');

// model imports
const { status, responseInstance } = require('../../Models/response');
const { chatSchema, chatEditSchema, chatDeleteSchema, getChatSchema, getUpdatesSchema } = require('../../Models/chat/chat');
const documentation = require('../../documentation/statusCodeDocumentation.json');
const schemaValidate = (req, schema) => {

    return new Promise((resolve, reject) => {
        const debug = require('debug')(`chat:schemaValidate}`);
        let error;
        if (schema == 'add') {
            error = chatSchema.validate(req.body).error;

        } else if (schema == 'edit') {
            error = chatEditSchema.validate(req.body).error;

        } else if (schema == 'delete') {
            error = chatDeleteSchema.validate(req.body).error;

        } else if (schema == 'getChat') {
            error = getChatSchema.validate(req.body).error;

        } else if (schema == 'getUpdates') {
            error = getUpdatesSchema.validate(req.body).error;

        }

        if (error) {
            debug(error.details);
            reject(new responseInstance(new status(6001, documentation[6001]), 'use a vadid data format'))
        } else {
            resolve(req.body);
        }
    });

}

const dbOperation = (body, operationType) => {
    const debug = require('debug')(`chat:${operationType}`);

    return new Promise((resolve, reject) => {
        db.getConnection((error, connection) => {
            if (error) {
                debug(`Error: ${error}`);
                reject(new responseInstance(new status(7002, documentation[7002]), 'this is a backend issue'));
            }

            let sql; let values;

            if (operationType == 'insert') {

                sql = 'CALL InsertMessage(?, ?, ?)';
                values = [body.conversationId, body.sender, body.message];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();

                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7003, documentation[7003]), 'this is a backend issue'));
                    } else {
                        if (result[0][0].status == 1101) {
                            reject(new responseInstance(new status(1101, documentation[1101]), 'user a valid conversation id'));
                        } else {
                            resolve(result[0][0]);
                        }
                    }
                });

            } else if (operationType == 'edit') {

                sql = 'CALL EditMessageText(?, ?, ?, ?)';
                values = [body.conversationId, body.messageId, body.sender, body.newMessage];

                connection.query(sql, values, (error, result, fields) => {
                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7003, documentation[7003]), 'this is a backend issue'));
                    } else {
                        if (result[0][0].status == 1102) {
                            reject(new responseInstance(new status(1102, documentation[1102]), 'be a valid user'));
                        } else {
                            resolve(result[0][0]);
                        }
                    }
                });

            } else if (operationType == 'delete') {

                sql = 'CALL DeleteMessage(?, ?, ?)';
                values = [body.conversationId, body.messageId, body.sender];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();

                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7003, documentation[7003]), 'this is a backend issue'));
                    } else {
                        if (result[0][0].status == 1103) {
                            reject(new responseInstance(new status(1103, documentation[1103]), 'an authorized operation was denied'));
                        } else {
                            resolve(result[0][0]);
                        }
                    }
                });

            } else if (operationType == 'getChat') {

                sql = 'CALL GetChat(?, ?)';
                values = [body.conversationId, body.lastMessageId];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();

                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7003, documentation[7003]), 'this is a backend issue'));
                    } else {
                        if (result[0][0].status == 1104) {
                            reject(new responseInstance(new status(1104), documentation[1104]), 'there is no chat with the given details');
                        } else {
                            resolve(result[0]);
                        }
                    }
                })
            }

        })
    })
};


const sender = (result, operationType, res) => {
    if (operationType == 'insert') {
        res.send(new responseInstance(new status(1201, documentation[1201]), result));
    } else if (operationType == 'edit') {
        res.send(new responseInstance(new status(1202, documentation[1202]), result));
    } else if (operationType == 'delete') {
        res.send(new responseInstance(new status(1203, documentation[1203]), result));
    } else if (operationType == 'getChat') {
        res.send(new responseInstance(new status(1204, documentation[1204]), result));
    }
}

module.exports = { schemaValidate, dbOperation, sender };