// mysql configurations
const mysql = require('mysql2');
const dbConfig = require('../../Config/dbConfig');
const db = mysql.createPool(dbConfig);

// model imports
const { status, responseInstance } = require('../../Models/response');
const { chatSchema, chatEditSchema, chatDeleteSchema } = require('../../Models/chat/chat');

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

        }

        if (error) {
            debug(error.details);
            reject(new responseInstance(new status(6001, 'invalid json content'), 'use a vadid data format'))
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
                reject(new responseInstance(new status(6012, 'unable to create connection with the database server'), 'this is a backend issue'));
            }

            let sql; let values;

            if (operationType == 'insert') {

                sql = 'CALL InsertMessage(?, ?, ?)';
                values = [body.conversationId, body.sender, body.message];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();

                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7002, 'unable to connnect to database'), 'this is a backend issue'));
                    } else {
                        if (result[0][0].status == 7004) {
                            reject(new responseInstance(new status(7004, 'the user is not a participant of the conversation'), 'user a valid conversation id'));
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
                        reject(new responseInstance(new status(7002, 'unable to connect to database'), 'this is a backend issue'));
                    } else {
                        if (result[0][0].status == 7005) {
                            reject(new responseInstance(new status(7005, 'the user is not authorized to edit the message'), 'be a valid user'));
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
                        reject(new responseInstance(new status(7002, 'unable to connect to database'), 'this is a backend issue'));
                    } else {
                        if (result[0][0].status == 7003) {
                            reject(new responseInstance(new status(7003, 'unable to delete message'), 'an authorized operation was denied'));
                        } else {
                            resolve(result[0][0]);
                        }
                    }
                });

            };

        })
    })
};


const sender = (result, operationType, res) => {
    if (operationType == 'insert') {
        res.send(new responseInstance(new status(1005, 'message is saved successfully'), result));
    } else if (operationType == 'edit') {
        res.send(new responseInstance(new status(1006, 'message is edited successfully'), result));
    } else if (operationType == 'delete') {
        res.send(new responseInstance(new status(1007, 'message is deleted successfully'), result));
    }
}

module.exports = { schemaValidate, dbOperation, sender };