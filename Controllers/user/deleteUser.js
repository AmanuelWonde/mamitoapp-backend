const db = require("../../Config/config");
const JWT = require("jsonwebtoken");
const bcrypt = require("bcryptjs");

module.exports = async (req, res) => {
    const token = req.header('auth-token');

    if (!JWT.verify(token, 'hiruy')) {
        return res.status(403).json({
            error: 'not authorized to delete user'
        });
    }

    const decoded = JWT.decode(token);
    // console.log('decoded -- ', decoded)
    let userData;

    try {
        let sql = 'CALL GetUserByUsername(?)'

        db.query(sql, [ decoded.username ], (err, result) => {
            if (result[0][0].password != null) {
                if (!bcrypt.compareSync(req.body.password, result[0][0].password)) {
                    if (err) res.status(500).json({ error: 'error while processing request' })
                    return res.status(403).json({
                        status: 1014,
                        error: "incorrect password"
                    })
                }
            } else {
                return res.status(404).json({
                    status: 1015,
                    error: "account is not found"
                })
            }

            try {
                let sql = 'DELETE FROM user WHERE username = ?';

                db.query(sql, [ decoded.username ], (err, result) => {
                    if (err) return res.status(500).send('error while processing request')
                    res.status(200).json({
                        status: 1016,
                        discription: 'account deleted successfully'
                    })
                    db.query('delete from `profile-images` where user_username = ?', [decoded.username], (err, result) => {
                        if (err) console.log(err)
                        else { console.log(result) }
                    })
                })

            } catch (err) {
                return res.status(404).json({
                    status: 1017,
                    error: 'unable to delete data'
                });
            }
        });

    } catch(error) {
        console.error(error);
        return res.status(500).send('error while processing request');
    }

}
