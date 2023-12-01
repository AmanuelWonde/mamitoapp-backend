// mysql configurations
const db = require('../../Config/dbConfig');

// socket.io configurations
const { io } = require('socket.io-client');
const socket = io('http://localhost:3001');

// model imports
const { status, responseInstance } = require('../../Models/response');
const { chatSchema, chatEditSchema, chatDeleteSchema, chatGetSchema, chatGetEdits, chatGet20Schema, chatMar } = require('../../Models/chat/chat');
const documentation = require('../../documentation/statusCodeDocumentation.json');
const schemaValidate = (req, schema) => {

    return new Promise((resolve, reject) => {
        const debug = require('debug')(`chat:schemaValidate}`);
        let error;
        if (schema == 'add') {                                  // 1
            error = chatSchema.validate(req.body).error;

        } else if (schema == 'edit') {                          // 2
            error = chatEditSchema.validate(req.body).error;

        } else if (schema == 'delete') {                        // 3
            error = chatDeleteSchema.validate(req.body).error;

        } else if (schema == 'get') {                           // 4
            error = chatGetSchema.validate(req.body).error;

        } else if (schema == 'getedits') {                      // 5
            error = chatGetEdits.validate(req.body).error;

        } else if (schema == 'getchat') {                       // 6
            error = chatGet20Schema.validate(req.body).error;

        } else if (schema == 'mar') {
            error = chatMar.validate(req.body).error; // 7
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

                sql = 'CALL InsertNewMessage(?, ?, ?)';
                values = [body.conversationId, body.sender, body.message];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();

                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7003, documentation[7003]), 'this is a backend issue'));
                    } else {
                        if (result[0][0].status == 1101) {
                            reject(new responseInstance(new status(1101, documentation[1101]), 'dont have access to send message to this conversation'));
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

            } else if (operationType == 'get') {

                sql = 'CALL GetNewMessages(?)';
                values = [body.username];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();

                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7003, documentation[7003]), 'this is a backend issue'));
                    } else {
                        debug(result);
                        if (0) {
                            reject(new responseInstance(new status(1104), documentation[1104]), 'there is no chat with the given details');
                        } else {
                            resolve(result[0]);
                        }
                    }
                })
            } else if (operationType == 'getedits') {

                sql = 'CALL GetEditedAndDeletedMessages(?)';
                values = [body.username];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();

                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7003, documentation[7003]), 'this is a backend issue'));
                    } else {
                        debug(result);
                        if (0) {
                            reject(new responseInstance(new status(1105), documentation[1105]), 'there is no chat with the given details');
                        } else {
                            resolve(result[0]);
                        }
                    }
                })
            } else if (operationType == 'getchat') {

                sql = 'CALL GetLast20Messages(?, ?)';
                values = [body.conversationId, body.earliestMessage];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();

                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7003, documentation[7003]), 'this is a backend issue'));
                    } else {
                        debug(result);
                        if (0) {
                            reject(new responseInstance(new status(1104, documentation[1104]), 'there is no chat with the given details'));
                        } else {
                            resolve(result)[0];
                        }
                    }
                })
            } else if (operationType == 'mar') {

                sql = 'CALL ReadMarker(?, ?)';
                values = [body.conversationId, body.username];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();

                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7003, documentation[7003]), 'this is a backend issue'));
                    } else {
                        debug(result);
                        if (0) {
                            reject(new responseInstance(new status(1104, documentation[1104]), 'there is no chat with the given details'));
                        } else {
                            resolve(result[0][0]);
                        }
                    }
                })
            }

        })
    })
};


const sender = (result, operationType, res) => {
    const statusCode =
        operationType == 'insert' ? 1201 :
            operationType == 'edit' ? 1202 :
                operationType == 'delete' ? 1203 :
                    operationType == 'get' ? 1204 :
                        operationType == 'getedits' ? 1205 :
                            operationType == 'getchat' ? 1206 :
                                operationType == 'mar' ? 1207 :
                                    1208;

    if (operationType == 'insert') {
        res.send(new responseInstance(new status(statusCode, documentation[statusCode]), result));
        socket.emit('chat', statusCode, result.receiver, result);
    } else if (operationType == 'edit') {
        res.send(new responseInstance(new status(statusCode, documentation[statusCode]), result));
        socket.emit('chat', statusCode, result.receiver, result);
    } else if (operationType == 'delete') {
        res.send(new responseInstance(new status(statusCode, documentation[statusCode]), result));
        socket.emit('chat', statusCode, result.receiver, result);
    } else if (operationType == 'get') {
        res.send(new responseInstance(new status(statusCode, documentation[statusCode]), result));
    } else if (operationType == 'getedits') {
        res.send(new responseInstance(new status(statusCode, documentation[statusCode]), result));
    } else if (operationType == 'getchat') {
        res.send(new responseInstance(new status(statusCode, documentation[statusCode]), result));
    } else if (operationType == 'mar') {
        res.send(new responseInstance(new status(statusCode, documentation[statusCode]), result));
        socket.emit('chat', statusCode, result.receiver, result);
    }
}

module.exports = { schemaValidate, dbOperation, sender };