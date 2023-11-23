// module imports and configs
const bcrypt = require('bcryptjs');
const JWT = require('jsonwebtoken')


// mysql configurations
const mysql = require('mysql2');
const dbConfig = require('../../Config/dbConfig');
const db = mysql.createPool(dbConfig);


// model imports
const { status, responseInstance } = require('../../Models/response');

module.exports = (req, res) => {
    res.send('service not available');
};