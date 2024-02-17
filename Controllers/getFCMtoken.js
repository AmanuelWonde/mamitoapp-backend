function getToken(username) {
    return new Promise((resolve, reject) => {
        db.getConnection((error, connection) => {
            if (error) {
                debug(`Error: ${error}`);
                reject(new responseInstance(new status(7001, documentation[7001]), 'this is backend issue'));
                return;
            }

            const sql = 'CALL GetDeviceId(?)';
            const values = [username];

            connection.query(sql, values, (error, result) => {
                connection.release();
                if (error) {
                    reject(error);
                    return;
                }
                resolve(result[0][0].deviceId);
            });
        });
    });
}