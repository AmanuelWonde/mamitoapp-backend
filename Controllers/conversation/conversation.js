// mysql configurations
const db = require('../../Config/config');

// socket configurations
const { io, fcm } = require('../../app');

// component imports
const { status, responseInstance } = require('../../Models/response');
const { updateConversation } = require('../../Models/conversation/conversation');
const documentation = require('../../documentation/statusCodeDocumentation.json');
const { getFCMtoken } = require('../getFCMtoken');

const p1 = (req) => {
    return new Promise((resolve, reject) => {
        const debug = require('debug')('upcon:p1');
        const { error } = updateConversation.validate(req.body);
        if (error) {
            debug(error.details[0].message);
            reject(new responseInstance(new status(6001, 'invalid json content'), error.details[0].message));
        } else {
            resolve(req.body);
        }
    })
}

const op1 = (body) => {
    return new Promise((resolve, reject) => {
        db.getConnection((error, connection) => {
            if (error) {
                debug(`Error: ${error}`);
                reject(new responseInstance(new status(7001, documentation[7001]), 'this is backend issue'));
            }

            const sql = 'CALL UpdateConversationStatus(?, ?)';
            const values = [body.id, body.op];

            connection.query(sql, values, (error, result) => {
                connection.release();
                if (error) {
                    reject(new responseInstance(new status(7002, documentation[7002]), 'this is a backend issue'));
                } else {
                    if (result[0][0].status == 1040) {
                        resolve(new responseInstance(new status(1040), result[0][0]));
                    } else if (result[0][0].status == 1041) {
                        resolve(new responseInstance(new status(1041), result[0][0]));
                    } else if (result[0][0].status == 1042) {
                        resolve(new responseInstance(new status(1042), result[0][0]));
                    }
                }
            });

        });
    })
}

const sender = (result, res) => {
    console.log('status', result.status);
    console.log('content', result.content);
    if (result.status.code == 1040) {
        res.send(result);
        io.emit(result.content['user-1'], result);

        getFCMtoken(result.content['user-1']).then(fcmToken => {
            if (fcmToken)
            fcm.messaging()
                .send({
                    token: fcmToken,
                    // notification: {
                    //     title: "Request accepted",
                    //     body: `${result.content['user-1']} accepted your chat request`,
                    // },
                    data: {
                        custom_notification: JSON.stringify({
                            title: "Request accepted",
                            body: `${result.content['user-1']} accepted your chat request`,
                        }),
                        details: JSON.stringify(result)
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
        })
    } else if (result.status.code == 1041) {
        res.send(result);
        io.emit(result.content.receiver, result);
    } else {
        res.send(result);
    }
}

module.exports = { p1, sender, op1 }
