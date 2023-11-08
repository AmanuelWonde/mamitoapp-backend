// module imports and configs
const express = require('express');
const router = express.Router();

// multer configurations imports
const { upload } = require('../Config/multer_config');

// model imports
const { userSchema } = require('../Models/user');
const { responseInstance } = require('../Models/response');

router.post('/signup', (req, res) => {
    const debug = require('debug')('user:signup');

    let p1 = new Promise((resolve, reject) => {
        let { error } = userSchema.validate(req.body);
        if (error) reject(new responseInstance(`Error: Invalid User Details`, error));
        else resolve(req.body);
    });

    function sender(heir) {
        res.send(new responseInstance('passed the test', heir));
    }

    p1
        .then((heir) => sender(heir))
        .catch((error) => { res.status(400).send(error); debug(error) });
});

module.exports = { router };