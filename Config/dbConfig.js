const mysql = require("mysql2");
const pool = mysql.createPool({
  host: '139.177.180.48',
  user: 'mamitogw_abelmaireg',
  password: 'ge!=)K[MpzuO',
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
