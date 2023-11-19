const pool = require("../Config/dbConfig");
class Questions {
  static async addQuestions(questions) {
    try {
      const windowId = "This is new window";
      for (i = 0; i < questions; i++) {
        let question = questions[i].question;
        //this is to insert question
        const [result] = await pool.query(`CALL InsertQuestion (?, ?)`, [
          windowId,
          question,
        ]);
        let insertedQuestionId = result.insertId;
        let choices = question[i].choices;

        for (j = 0; j < choices; j++) {
          //this is to insert choices of the question
          await pool.query(`CALL InsertChoice (?, ?)`, [insertedQuestionId, j]);
        }
      }
      return { message: "Questions inserted successfully" };
    } catch (error) {
      console.log(error);
      return { err: "Something went wrong please try again!" };
    }
  }

  static async viewQuestions(windowId) {
    try {
      const [result] = await pool.query(`CALL GetAllQuestions(?)`, [windowId]);
      console.log(result);
      return { message: "Questions retrieved successfully", result };
    } catch (error) {
      return { err: "Can't retriev questions please try again!" };
    }
  }
}
module.exports = Questions;
//To add questions: [{question: car or dog, choices: [cat, dog]}]

//Sample to send questions: {message: "all questions", questions: [{id: 2, question: "dog or cat", choices: [{id: 1, choice: dog}]}]}
