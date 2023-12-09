const pool = require("../Config/dbConfig");
class Questions {
  static async addQuestions(questions, images, windowName, startDate, endDate) {
    try {
      await pool.query("START TRANSACTION");

      await pool.query(`CALL InsertWindow (?, ?, ?, @insertedId)`, [
        windowName,
        startDate,
        endDate,
      ]);

      const [windowIdResult] = await pool.query(
        "SELECT @insertedId AS inserted_id"
      );

      const windowId = windowIdResult[0].inserted_id;

      for (let i = 0; i < questions.length; i++) {
        const question = questions[i].question;
        const value = questions[i].value;

        await pool.query(`CALL InsertQuestion (?, ?, ?, @inserted_id)`, [
          question,
          windowId,
          value,
        ]);

        const [insertedIdResult] = await pool.query(
          "SELECT @inserted_id AS inserted_id"
        );

        const questionId = insertedIdResult[0].inserted_id;
        const choices = questions[i].choices;

        for (let j = 0; j < choices.length; j++) {
          const choice = choices[j].name;
          let image;

          const findImage = images.find(
            (element) =>
              element.fieldname === `questions[${i}][choices][${j}][image]`
          );

          if (findImage) {
            image = findImage.filename;
          } else {
            image = null;
          }

          await pool.query(`CALL InsertChoice (?, ?, ?)`, [
            questionId,
            choice,
            image,
          ]);
        }
      }

      await pool.query("COMMIT");
      return { message: "Questions inserted successfully" };
    } catch (error) {
      await pool.query("ROLLBACK");
      console.log(error);
      return { err: "Something went wrong please try again!" };
    }
  }

  static async viewQuestions(windowId) {
    try {
      const [result] = await pool.query(`CALL CurrentWindowQuestions(?)`, [
        windowId,
      ]);
      return { message: "Questions retrieved successfully", result: result[0] };
    } catch (error) {
      console.log(error);
      return { err: "Can't retriev questions please try again!" };
    }
  }
}
module.exports = Questions;
//To add questions: [{question: car or dog,value:9, choices: [cat, dog]}]

//Sample to send questions: {message: "all questions", questions: [{question: "dog or cat", id: 2, choices: [{id: 1, choice: dog}]}]}
// select all from the questions table where win_id = 1 left join choices on  questionId = quesId and windwId
