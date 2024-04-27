const pool = require("../Config/dbConfig");

class Answers {
  static async addAnswers(windowId, userName, answers, mood) {
    try {
      await pool.query("START TRANSACTION");

      for (let i = 0; i < answers.length; i++) {
        const questionId = answers[i].questionId;
        const choiceId = answers[i].choiceId;
        await pool.query(`CALL InsertUserAnswers(?, ?, ?, ?, ?)`, [
          windowId,
          userName,
          questionId,
          choiceId,
          mood,
        ]);
      }

      await pool.query("COMMIT");

      return { message: "Answers inserted successfully." };
    } catch (err) {
      console.log(err);
      await pool.query("ROLLBACK");
      return { error: "something went wrong please try again" };
    }
  }
}

module.exports = Answers;
//answers data formate that comes from the frontend
//{windowId: 5, userName: "amanw", answers: [{ questionId: 1, choiceId: 4}]}
