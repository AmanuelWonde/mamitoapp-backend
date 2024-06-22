const db = require("../../Config/config");
const JWT = require("jsonwebtoken");
const bcrypt = require("bcryptjs");

module.exports = (req, res) => {
    const token = req.header('auth-token');

    if (!JWT.verify(token, 'hiruy')) {
        return res.status(403).json({
            error: 'not authorized to delete user'
        });
    }

    const decoded = JWT.decode(token);
    let userData;

    try {
        let sql = 'CALL GetUserByUsername(?)'

        db.query(sql, [ decoded.username ], (err, result) => {
            if (!bcrypt.compareSync(req.body.password, result[0][0].password)) {
                if (err) res.status(500).json({ error: 'error while processing request' })
                return res.status(403).json({error: "incorrect password"})
            }
        });

    } catch(error) {
        console.error(error);
        return res.status(500).send('error while processing request');
    }

    try {
        let sql = 'DELETE FROM user WHERE username = ?';

        db.query(sql, [ decoded.username ], (err, result) => {
            if (err) return res.status(500).send('error while processing request')
            console.log(result);
            res.send('done')
        })
    } catch (err) {
        console.error(err);
        return res.status(404).send('unable to delete data');
    }

}
