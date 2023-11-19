const pool = require("../Config/dbConfig");

class Answers {
  static async addAnswers(answers) {
    try {
      const windowId = answers;
      const userId = answers.userId;
      const answers = answers.answers;
      for (i = 0; i < answers.length; i++) {
        let choiceId = answers[i].choiceId;
        let questionId = answers[i].questionId;
        pool.query(`CALL InsertAnswer(?, ?, ?)`, [
          choiceId,
          questionId,
          userId,
        ]);
      }

      await pool.query(`CALL InsertIntoUserHasWindows(?, ?)`, [
        windowId,
        userId,
      ]);

      return { message: "Answers inserted successfully." };
    } catch (err) {
      console.log(err);
      return { error: "something went wrong please try again" };
    }
  }
}

module.exports = Answers;
//answers data formate that comes from the frontend
//{windowId: 5, userId: 3, answers: [{ questionId: 1, choiceId: 4}]}
