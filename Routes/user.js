// express router declaretion
const express = require("express");
const router = express.Router();

router.post('/signup', require('../Middleware/user/signup'));

router.get('/login', require('../Middleware/user/login'));

router.post('/profileimageupload', require('../Middleware/auth/auth'), require('../Middleware/user/uploadprofilepic'))

module.exports = { router };
