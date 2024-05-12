const mysql = require("mysql2");
const pool = mysql.createPool({
  host: "localhost", // mamitoapp.com
  user: "AbelMaireg", // mamitogw_abel
  password: "6006174009010", // X_Z)qu6;o$w6 ??-*Z=Un;NJk
  database: "mamitogw_mamito",
  waitForConnections: true,
  connectionLimit: 1,
  maxIdle: 10,
  idleTimeout: 60000,
  queueLimit: 1,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
});

module.exports = pool;
