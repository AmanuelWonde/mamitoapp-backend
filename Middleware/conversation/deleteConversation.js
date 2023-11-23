// mysql configurations
const db = require('../../Config/dbConfig');

// model imports
const { status, responseInstance } = require('../../Models/response');
const { newConversation } = require('../../Models/conversation/conversation');
const documentation = require('../../documentation/statusCodeDocumentation.json')

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
                    reject(new responseInstance(new status(7002, documentation[7002]), 'this is backend issue'));
                }

                const sql = 'CALL DeleteConversation(?, ?)';
                const values = [body.user1, body.user2];

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
                            resolve(1025);
                        }
                    }
                });
            })
        })
    }

    const sender = (code) => {
        res.status(202).send(new responseInstance(new status(code, documentation[code]), "everything which is subordinate to the conversation is permanently deleted."))
    }

    p1
        .then((body) => deleteConversation(body))
        .then((code) => sender(code))
        .catch(error => { debugg(error); res.send(error) });
}