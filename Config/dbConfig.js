const mysql = require("mysql2");
const pool = mysql.createPool({
  host: 'localhost',
  user: 'mamitogw_abelmaireg',
  password: '+=S=2-b~9!k;',
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
