const pool = require("../Config/dbConfig");

class ProfileQuestions {
  static async add(questions) {
    try {
      //[{question: "amanuel", value, choices: ["me", 'him']}]
      for (let i = 0; i < questions.length; i++) {
        const { question, value, choices } = questions[i];
        await pool.query(`CALL AddProfileQuestions(?, ?, @id)`, [
          question,
          value,
        ]);

        const [insertedIdResult] = await pool.query("SELECT @id AS questionId");
        const questionId = insertedIdResult[0].questionId;

        for (let i = 0; i < choices.length; i++) {
          await pool.query(`CALL InsertProfileQuestionChoices(?, ?)`, [
            questionId,
            choices[i],
          ]);
        }
      }
      return { message: "Profile Questions added Successfully." };
    } catch (err) {
      console.log(err);
      return { error: "Falid to add profile questions please try again!" };
    }
  }

  static async view(username) {
    try {
    } catch (err) {}
  }

  static async updateAnswer(username, answers) {
    try {
      const [isAnswerd] = await pool.query(
        `SELECTL * FROM  profile-question-answers`
      );
      if (isAnswerd) {
        for (let i = 0; i < answers.length; i++) {
          const questionId = answers[i].questionId;
          const choiceId = answers[i].choiceId;
          await pool.query(`CALL UpdateProfileQuestionsAnswer(?, ?, ?)`, [
            username,
            questionId,
            choiceId,
          ]);
        }
        return { message: "Profile question answers updated successfully!" };
      } else {
        for (let i = 0; i < answers.length; i++) {
          const questionId = answers[i].questionId;
          const choiceId = answers[i].choiceId;
          await pool.query(`CALL AddProfileQuestionsAnswer(?, ?, ?)`, [
            username,
            questionId,
            choiceId,
          ]);
        }
        return { message: "Profile question answers added successfully!" };
      }
    } catch (err) {
      console.log(err);
      return { error: "Can't add or update profile question answers!" };
    }
  }
}

module.exports = { ProfileQuestions };
