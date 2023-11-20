// express router declaretion
const express = require("express");
const router = express.Router();


// mysql configurations
const mysql = require('mysql2');
const dbConfig = require('../Config/dbConfig');
const db = mysql.createPool(dbConfig);

router.post('/signup', require('../Middleware/user/signup'));

router.get('/login', require('../Middleware/user/login'));

router.post('/profileimageupload', require('../Middleware/auth/auth'), require('../Middleware/user/uploadprofilepic'))

module.exports = { router };
