// mysql configurations
const db = require('../../Config/config');

// model imports
const { status, responseInstance } = require('../../Models/response');

module.exports = (req, res) => {
    res.send('service not available');
};