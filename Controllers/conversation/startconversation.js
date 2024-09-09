// mysql configurations
const db = require('../../Config/config');

// socket configurations
const { io, fcm} = require('../../app');

// component imports
const { status, responseInstance } = require('../../Models/response');
const { newConversation } = require('../../Models/conversation/conversation');
const documentation = require('../../documentation/statusCodeDocumentation.json');
const { getFCMtoken } = require('../getFCMtoken');

const p1 = (req) => {
    return new Promise((resolve, reject) => {
        const { error } = newConversation.validate(req.body);
        if (error) {
            reject(new responseInstance(new status(6001, 'invalid json content'), error.details[0].message));
        } else {
            resolve(req.body);
        }
    });
}

const insertConversation = (body) => {
    return new Promise((resolve, reject) => {
        db.getConnection((error, connection) => {
            if (error) {
                reject(new responseInstance(new status(7001, documentation[7001]), 'this is backend issue'));
            }

            const sql = 'CALL InsertConversation(?, ?, ?)';
            const values = [body.user1, body.user2, body.match];

            connection.query(sql, values, (error, result, fields) => {
                connection.release();

                if (error) {
                    console.log(error)
                    reject(new responseInstance(new status(7002, documentation[7002]), 'this is a backend issue'));
                    return;
                } else {
                    if (result[0][0].status == 1021) {
                        reject(new responseInstance(new status(1021, documentation[1021]), "the coversation with the user is already existed"));
                    } else {
                        resolve(result[0][0]);
                    }
                }
            });

        });

    })
}

const sender = (result, res) => {
    res.send(new responseInstance(new status(1020), result));
    io.emit(result["user-2"], new responseInstance(new status(1020), result));

    getFCMtoken(result['user-2']).then(fcmToken => {
        if (fcmToken)
            fcm.messaging()
            .send({
                    token: fcmToken,
                    notification: {
                        title: 'new request',
                        body: result["user-1"],
                    },
                    android: {
                        priority: "high",
                    }
                })
            .then(response => {
                    console.log('notification success: ', response);
                })
            .catch(error => {
                    console.log('notification error: ', error);
                })
    });

}

module.exports = { sender, insertConversation, p1 }
