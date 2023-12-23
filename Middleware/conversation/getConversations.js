// mysql configurations
const db = require('../../Config/config');

// component imports
const { status, responseInstance } = require('../../Models/response');
const { getConversation } = require('../../Models/conversation/conversation');
const documentation = require('../../documentation/statusCodeDocumentation')

module.exports = (req, res) => {
    const debugg = require('debug')('getconv:');
    const p1 = new Promise((resolve, reject) => {
        const debug = require('debug')('getconv:p1');
        const { error } = getConversation.validate(req.body);
        if (error) {
            reject(new responseInstance(new status(6001, documentation[6001]), error.details[0].message));
        } else {
            resolve(req.body);
        }
    });

    const getConv = (body) => {
        const debug = require('debug')('getconv:getconv');
        return new Promise((resolve, reject) => {
            db.getConnection((error, connection) => {
                if (error) {
                    debug(`Error: ${error}`);
                    reject(new responseInstance(new status(7002, documentation[7002]), 'this is backend issue'));
                }

                const sql = 'CALL GetConversations(?)';
                const values = [body.username];

                connection.query(sql, values, (error, result, fields) => {
                    connection.release();
                    if (error) {
                        debug(`Error: ${error}`);
                        reject(new responseInstance(new status(7003, documentation[7003]), error));
                    } else {
                        resolve(result[0]);
                    }

                });
            })
        })
    }

    const sender = (result) => {
        delete result.password;
        res.send(new responseInstance(new status(1023, documentation[1023]), result));
    }

    p1
        .then((body) => getConv(body))
        .then((result) => sender(result))
        .catch(error => { debugg(error); res.send(error) });
}