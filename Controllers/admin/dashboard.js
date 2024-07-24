const db = require('../../Config/config');

const controller = (req, res) => {

  const sql2 = `
  SELECT
    (SELECT COUNT(*) FROM mamitogw_mamito.user) AS "totalUsers",
    (SELECT COUNT(*) FROM mamitogw_mamito.user WHERE verified = TRUE) AS "verifiedUsers",
    (SELECT COUNT(*) FROM mamitogw_mamito.user WHERE \`created-at\`  >= DATE_SUB(NOW(), INTERVAL 3 DAY)) AS "newUsers",
    (SELECT COUNT(*) FROM mamitogw_mamito.windows) AS "totalWindows",
    (SELECT COUNT(DISTINCT window_id) FROM mamitogw_mamito.answers) AS "answeredWindows",
    (SELECT COUNT(*) FROM mamitogw_mamito.questions) AS "questions"
`

  try {

    db.query(sql2, (err, result) => {
      if (err) {
        console.log(err);
        return res.status(400).json({ error: "error while processing request" });
      }

      return res.status(200).json({ success: true, data: result });
    })

  } catch(error) {
    res.status(400).json({ error: "error while processing request"});
  }

}

module.exports = controller;
