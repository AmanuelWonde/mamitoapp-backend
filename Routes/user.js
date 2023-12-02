// express router declaretion
const express = require("express");
const router = express.Router();
const { upload } = require('../Config/multerConfig');

router.post('/signup', require('../Middleware/user/signup'));

router.get('/login', require('../Middleware/user/login'));

router.post('/profileimageupload', (req, res) => {

    upload(req, res, (err) => {
        if (err) {

            console.log(req);
            res.send(err);

        }
    })
});

module.exports = { router };
