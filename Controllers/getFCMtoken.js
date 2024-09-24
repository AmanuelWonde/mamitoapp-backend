// mysql configurations
const db = require('../Config/config');

function getFCMtoken(username) {
    return new Promise((resolve, reject) => {
        db.getConnection((error, connection) => {

            const sql = 'CALL GetDeviceId(?)';
            const values = [username];

            connection.query(sql, values, (error, result) => {
                connection.release();
                if (error) {
                    reject(error);
                }

                let token = result[0][0].deviceId? result[0][0].deviceId: null;
                resolve(token);
            });
        });
    });
}

module.exports = { getFCMtoken }
