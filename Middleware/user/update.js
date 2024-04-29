// module imports and configs
const JWT = require('jsonwebtoken');

// mysql configurations
const db = require('../../Config/config');

// model imports
const { userUpdateSchema } = require('../../Models/User');
const { status, responseInstance } = require('../../Models/response');
const documentation = require('../../documentation/statusCodeDocumentation.json');

module.exports = (req, res) => {

    let p1 = new Promise((resolve, reject) => {
        let { error } = userUpdateSchema.validate(req.body);
        if (error) reject(new responseInstance(new status(6001, documentation[6001]), error.details[0].message));
        else resolve(req.body);
    });

    let update = (body) => {
        const debug = require('debug')('user:update');
        return new Promise((resolve, reject) => {
            db.getConnection((error, connection) => {
                if (error) {
                    console.log(error);
                    reject(new responseInstance(new status(7001, documentation[7001]), 'this is backend issue'));
                }
                const sql = 'CALL UpdateUser(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
                const values = [body.username, body.name, body.gender, body.birthdate, body.phone, body.bio, body.religion, body.changeOneSelf, body.latitude, body.longitude];

                connection.query(sql, values, (error, result, fields) => {
                    console.log(result);
                    if (error) {
                        debug(error);
                        reject(new responseInstance(new status(7002), "this is a backend issue"));
                    } else {
                        if (result[0][0].status == 1031) {
                            reject(new responseInstance(new status(1031), "update failed!"));
                        } else {
                            delete result[0][0].status;
                            resolve(result[0][0]);
                        }
                    }


                })
            })
        })
    }

    let sender = (result) => {
        res.setHeader('auth-token', JWT.sign(result, "hiruy")).send(new responseInstance(new status(1030), result));
    }

    p1
        .then((body) => update(body))
        .then((result) => sender(result))
        .catch((error) => { res.send(error) })
}