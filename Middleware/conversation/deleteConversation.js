// mysql configurations
const db = require('../../Config/dbConfig');
const Joi = require('joi');

// model imports
const { status, responseInstance } = require('../../Models/response');
const documentation = require('../../documentation/statusCodeDocumentation.json');
const deleteConv = Joi.object({
    conversationId: Joi.number().required(),
    username: Joi.string().min(6).required()
});

const { io } = require('socket.io-client');
const socket = io('http://localhost:3001');

module.exports = (req, res) => {
    const debugg = require('debug')('clearconversation');
    const p1 = new Promise((resolve, reject) => {
        const debug = require('debug')('clearconversation:p1');
        const { error } = deleteConv.validate(req.body);
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
                    reject(new responseInstance(new status(7002, documentation[7002]), 'this is backend issue'));
                }

                const sql = 'CALL DeleteConversation(?, ?)';
                const values = [body.conversationId, body.username];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();

                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7002, documentation[7002]), 'this is a backend issue'));
                        return;
                    } else {
                        if (result[0][0].status == 1024) {
                            reject(new responseInstance(new status(1024, documentation[1024]), "the coversation with the user does not exit"));
                        } else {
                            console.log(result)
                            resolve(result[0][0].username);
                        }
                    }
                });
            })
        })
    }

    const sender = (username) => {
        res.status(200).send(new responseInstance(new status(1025, documentation[1025]), "everything which is subordinate to the conversation is permanently deleted."));
        socket.emit('deleted_conversation', username, req.body.conversationId);
    }

    p1
        .then((body) => deleteConversation(body))
        .then((code) => sender(code))
        .catch(error => { console.log(error); res.send(error) });
}