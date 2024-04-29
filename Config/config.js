const mysql = require("mysql2");
const pool = mysql.createPool({
  host: "localhost", // mamitoapp.com
  user: "AbelMaireg", // mamitogw_amanuelwonde
  password: "6006174009010", // X_Z)qu6;o$w6
  database: "mamitogw_mamito",
  waitForConnections: true,
  connectionLimit: 0,
  maxIdle: 10,
  idleTimeout: 60000,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
});

module.exports = pool;
