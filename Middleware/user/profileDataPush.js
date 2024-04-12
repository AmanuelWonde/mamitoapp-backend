
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
                        console.log();
                });
                
                sql = 'CALL insertKindOfPerson(?, ?, ?)';
                for (let key in body.kindOfPerson) {
                    values = [body.username, key, body.kindOfPerson[key]];
                    connection.query(sql, values, (err, result) => {
                        if (err)
                            console.log(err);
                        else
                            console.log();
                    });
                }

                resolve('1030');
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