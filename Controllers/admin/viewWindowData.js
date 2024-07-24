const db = require("../../Config/config");

const controller = (req, res) => {
  const sql = `
SELECT
    usr.username as "id",
    (SELECT DATE(usr.birthdate)) as "birthday",
    usr.religion as "religion",
    usr.gender as "gender",
    CONCAT(usr.latitude, ", ", usr.longitude) as "registeredLocation",
    usr.\`created-at\` as "signUpDate",
    (SELECT TIME(usr.\`created-at\`)) as "signUpTime",
    win.name as "collectionName",
    que.question as "questionType",
    ans.mood as "stateOfMood",
    (SELECT choice FROM mamitogw_mamito.choices cho WHERE cho.questions_id = ans.questions_id LIMIT 1) AS "questionChoice1",
    (SELECT choice FROM mamitogw_mamito.choices cho WHERE cho.questions_id = ans.questions_id LIMIT 1 OFFSET 1) AS "questionChoice2",
    (SELECT choice FROM mamitogw_mamito.choices cho WHERE cho.id = ans.choice_id LIMIT 1) AS "choosenAnswer",
    (SELECT DATE(ans.created_at)) as "windowLoggedInDate",
    (SELECT TIME(ans.created_at)) as "windowLoggedInTime",
    (SELECT COUNT(DISTINCT mood) FROM mamitogw_mamito.answers ans2 WHERE ans.user_username = ans2.user_username) as "totalEmotionsLogged",
    (SELECT GROUP_CONCAT(DISTINCT mood SEPARATOR ", ") FROM mamitogw_mamito.answers as ans3 WHERE ans.user_username = ans3.user_username) as "listOfLoggedInEmotions",
    (SELECT COUNT(DISTINCT window_id) FROM mamitogw_mamito.answers ans4 WHERE ans.user_username = ans4.user_username) as "totalWindowLogged",
    (SELECT "android") as "deviceType"
FROM mamitogw_mamito.answers ans
LEFT JOIN mamitogw_mamito.user usr
  ON ans.user_username = usr.username
LEFT JOIN mamitogw_mamito.windows win
  ON ans.window_id = win.id
LEFT JOIN mamitogw_mamito.questions que
  ON que.windows_id = win.id
ORDER BY window_id DESC, user_username`;

  db.query(sql, (err, result) => {
    if (err) {
      console.log(err);
      return res.status(400).json({ error: "error while processing request" });
    }

    return res.status(200).json({ success: true, data: result });
  });
};

module.exports = controller;
