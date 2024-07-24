const db = require('../../Config/config');

const controller = (req, res) => {

  const sql = `
SELECT 
	DISTINCT win.name as "collectionName", win.created_at as "createdAt",
	CASE
		WHEN ans.id IS NULL THEN "not answered"
        ELSE "answered"
	END AS status,
    (SELECT COUNT(DISTINCT ans2.user_username) FROM mamitogw_mamito.answers ans2 WHERE ans2.window_id = ans.window_id) AS "users that answered",
    (SELECT COUNT(DISTINCT ans2.user_username) 
     FROM mamitogw_mamito.answers ans2 
     JOIN mamitogw_mamito.user usr2 ON ans2.user_username = usr2.username 
     WHERE ans2.window_id = ans.window_id AND usr2.gender = 'M') AS "male users",
    (SELECT COUNT(DISTINCT ans2.user_username) 
     FROM mamitogw_mamito.answers ans2 
     JOIN mamitogw_mamito.user usr2 ON ans2.user_username = usr2.username 
     WHERE ans2.window_id = ans.window_id AND usr2.gender = 'F') AS "female users"
FROM mamitogw_mamito.windows win
LEFT JOIN mamitogw_mamito.answers ans
	ON win.id = ans.window_id
LEFT JOIN mamitogw_mamito.user usr
	ON ans.user_username = usr.username;
`

  const sql2 = `
  SELECT
    (SELECT COUNT(*) FROM mamitogw_mamito.user) AS "totalUsers",
    (SELECT COUNT(*) FROM mamitogw_mamito.user WHERE verified = TRUE) AS "verifiedUsers",
    (SELECT COUNT(*) FROM mamitogw_mamito.user WHERE \`created-at\`  >= DATE_SUB(NOW(), INTERVAL 3 DAY)) AS "newUsers",
    (SELECT COUNT(*) FROM mamitogw_mamito.windows) AS "totalWindows",
    (SELECT COUNT(DISTINCT window_id) FROM mamitogw_mamito.answers) AS "answeredWindows",
    (SELECT COUNT(*) FROM mamitogw_mamito.questions) AS "questions"
`

  let dashboard = {
    dashboard: null,
    windows_data: null
  };

  db.query(sql2, (err, result) => {
    if (err) {
      console.log(err);
      return res.status(400).json({ error: "error while processing request" });
    }

    dashboard.dashboard = result
  })

  db.query(sql, (err, result) => {
    if (err) {
      console.log(err);
      return res.status(400).json({ error: "error while processing request" });
    }

    dashboard.windows_data = result;
    return res.status(200).json({ success: true, data: dashboard });
  })

}

module.exports = controller;
