// module imports and configs
const JWT = require('jsonwebtoken');

// mysql configurations
const db = require('../../Config/config');

// model imports
const { status, responseInstance } = require('../../Models/response');
const documentation = require('../../documentation/statusCodeDocumentation.json');

module.exports = (req, res) => {
    let update = (body) => {
        return new Promise((resolve, reject) => {
            db.getConnection((error, connection) => {
                if (error) {
                    reject(new responseInstance(new status(7001), 'this is backend issue'));
                }
                
                let sql = 'CALL insertProfileData(?, ?, ?, ?)';
                let values = [body.username, body.employmentStatus, body.rangeOfSearch, body.rightPath];

                connection.query(sql, values, (err, result) => {
                    if (err)
                        console.log(err);
                    else
                        console.log(result);
                });
                
                sql = 'CALL inserKindOfPerson(?, ?, ?)';
                for (let key in body.kindOfPerson) {
                    values = [body.username, key, body.kindOfPerson[key]];
                    connection.query(sql, values, (err, result) => {
                        if (err)
                            console.log(err);
                        else
                            console.log(result);
                    });
                }

                resolve('1030');

                // connection.query(sql, values, (error, result) => {
                //     if (error) {
                //         console.log(error)
                //         reject(new responseInstance(new status(7002), "this is a backend issue"));
                //     } else {
                //         if (result[0][0].status == 1091) {
                //             reject(new responseInstance(new status(1091), "profila data push failed!"));
                //         } else {
                //             resolve(result[0][0]);
                //         }
                //     }
                // })
            })
        })
    }

    let sender = (result) => {
        res.send(new responseInstance(new status(1030), result));
    }

    update(req.body)
        .then((result) => sender(result))
        .catch((error) => { res.send(error) })
}