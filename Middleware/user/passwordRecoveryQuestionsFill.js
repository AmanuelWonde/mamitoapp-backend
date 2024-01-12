// mysql configurations
const db = require('../../Config/config');

// model imports
const { questionFillSchema } = require('../../Models/user');
const { status, responseInstance } = require('../../Models/response');
const documentation = require('../../documentation/statusCodeDocumentation.json');

module.exports = (req, res) => {
    let p1 = new Promise((resolve, reject) => {
        let { error } = questionFillSchema.validate(req.body);
        if (error) reject(new responseInstance(new status(6001, documentation[6001]), error.details[0].message));
        else resolve(req.body);
    });

    let store = (body) => {
        return new Promise((resolve, reject) => {

            db.getConnection((error, connection) => {
                if (error) {
                    reject(new responseInstance(new status(7001), 'this is a backend issue'));
                }

                const sql = 'CALL SaveRecoveryAnswers(?,?,?,?,?,?,?)';
                const values = [body.username, body.id1, body.id2, body.id3, body.ans1, body.ans2, body.ans3];

                connection.query(sql, values, (error, result) => {
                    if (error) {
                        console.log(error);
                        reject(new responseInstance(new status(7002), 'this is a backend issue'));
                    } else {
                        if (result[0][0].status == 1051) {
                            reject(new responseInstance(new status(1051), 'unable to save answers to the questions'));
                        } else {
                            resolve(result[0][0].status);
                        }
                    }
                })

            })

        })
    }

    let sender = () => {
        res.send(new responseInstance(new status(1050)))
    }

    p1
        .then((body) => store(body))
        .then((result) => sender())
        .catch((error) => res.send(error))
}