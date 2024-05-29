const mysql = require("mysql2/promise");
// Localhost connection
// const pool = mysql.createPool({
//   host: "localhost",
//   user: "root",
//   password: "wonde67@AM",
//   database: "mamitoapp",
//   waitForConnections: true,
//   connectionLimit: 0,
//   maxIdle: 10,
//   idleTimeout: 60000,
//   queueLimit: 0,
//   enableKeepAlive: true,
//   keepAliveInitialDelay: 0,
// });

// server db configeration
const pool = mysql.createPool({
  host: "mamitoapp.com",
  user: "mamitogw_amanuelwonde",
  password: "X_Z)qu6;o$w6",
  database: "mamitogw_mamito",
  waitForConnections: true,
  connectionLimit: 0,
  maxIdle: 10,
  idleTimeout: 60000,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
});

// Set the time zone for each connection when it is created.
pool.on("connection", function (connection) {
  connection.query("SET time_zone = '+03:00'", (err) => {
    if (err) {
      console.error("Failed to set time zone for connection:", err);
    } else {
      console.log("Time zone set to Africa/Nairobi for connection.");
    }
  });
});
module.exports = pool;
