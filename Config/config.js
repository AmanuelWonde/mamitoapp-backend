const mysql = require("mysql2");
const pool = mysql.createPool({
    host: process.env.dbip || "localhost",
    user: process.env.db || "AbelMaireg",
    password: process.env.dbpd || "6006174009010",
    database: "mamitogw_mamito",
    waitForConnections: true,
    connectionLimit: 0,
    maxIdle: 10,
    idleTimeout: 60000,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0,
});

console.log(process.env)

module.exports = pool;