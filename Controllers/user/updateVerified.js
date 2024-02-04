// mysql configurations
const db = require('../../Config/config');
const Joi = require('joi');

// socket.io configurations
const { io } = require('../../app');

// model imports
const { status, responseInstance } = require('../../Models/response');
// const { updateVerification } = require('../../Models/chat/chat');
const documentation = require('../../documentation/statusCodeDocumentation.json');
const updateVerification = Joi.object({
    username: Joi.string().required(),
    verification: Joi.number().required(),
})

const validateSchema = (req) => {
    return new Promise((resolve, reject) => {
        const debug = require('debug')('updateverfied:p1');
        const { error } = updateVerification.validate(req.body);
        if (error) {
            debug(error.details[0].message);
            reject(new responseInstance(new status(6001), error.details[0].message));
        } else {
            resolve(req.body);
        }
    })
}

const update = (body) => {
    const debug = require('debug')('updateVerified:update');
    return new Promise((resolve, reject) => {
        db.getConnection((error, connection) => {
            if (error) {
                debug(`Error: ${error}`);
                reject(new responseInstance(new status(7002, documentation[7002]), 'this is backend issue'));
            }

            const sql = 'CALL updateVerified(?, ?)';
            const values = [body.username, body.verification];

            connection.query(sql, values, (error, result, fields) => {
                connection.release();

                if (error) {
                    debug(`Error: ${error}`);
                    reject(new responseInstance(new status(7002, documentation[7002]), 'this is a backend issue'));
                    return;
                } else {
                    resolve(result[0][0]);
                }
            });
        })
    })
}

const sender = (req, res, result) => {
    res.status(200).send(new responseInstance(new status(result.status), "verification updated"));
    console.log(req.body.username);
    io.emit(req.body.username, new responseInstance(new status(result.status), "verification updated"));
}

module.exports = { validateSchema, update, sender };