// mysql configurations
const mysql = require('mysql2');
const dbConfig = require('../../Config/dbConfig');
const db = mysql.createPool(dbConfig);

// model imports
const { status, responseInstance } = require('../../Models/response');

module.exports = (req, res) => {
    const debug = require('debug')('getchat:');
    return new Promise((resolve, reject) => {

    })
}