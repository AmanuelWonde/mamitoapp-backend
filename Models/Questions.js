const pool = require("../Config/dbConfig");

class Questions {
  static async addQuestions(
    questions,
    images,
    windowName,
    startDate,
    endDate,
    mood,
    minAge,
    maxAge
  ) {
    try {
      await pool.query("START TRANSACTION");
      await pool.query(`CALL InsertWindow (?, ?, ?, ?, ?, ?, @insertedId)`, [
        windowName,
        mood,
        parseInt(minAge),
        parseInt(maxAge),
        startDate,
        endDate,
      ]);

      const [windowIdResult] = await pool.query(
        "SELECT @insertedId AS inserted_id"
      );
      const windowId = windowIdResult[0].inserted_id;
      console.log(questions);
      for (let i = 0; i < questions.length; i++) {
        const question = questions[i].question;
        const value = questions[i].value;
        const targetGender = questions[i].targetGender;
        await pool.query(`CALL InsertQuestion (?, ?, ?, ?, @inserted_id)`, [
          question,
          windowId,
          value,
          targetGender,
        ]);

        const [insertedIdResult] = await pool.query(
          "SELECT @inserted_id AS inserted_id"
        );

        const questionId = insertedIdResult[0].inserted_id;
        const choices = questions[i].choices;

        for (let j = 0; j < choices.length; j++) {
          const choice = choices[j].choice;
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

  static async viewQuestions(username, gender) {
    try {
      const [getCurrentWindow] = await pool.query(
        `CALL GetCurrentOrNextWindow()`
      );

      const [currentWindow] = [getCurrentWindow[0]];
      const windowId = currentWindow[0].CurrentWindowID;

      if (windowId) {
        const [isUserAnsweredWindow] = await pool.query(
          ` CALL CheckIfUserAnswersWindow(?, ?)`,
          [username, windowId]
        );
        const [isAnswered] = isUserAnsweredWindow[0];

        if (isAnswered.UserAnsweredWindow) {
          return {
            message: "success",
            data: {
              window: false,
              nextWindowStartTime: currentWindow[0].NextWindowStartTime,
            },
          };
        }

        const [result] = await pool.query(`CALL CurrentWindowQuestions(?, ?)`, [
          windowId,
          gender,
        ]);

        return {
          message: "success",
          data: {
            window: true,
            windowId: windowId,
            nextWindowStartTime: currentWindow[0].NextWindowStartTime,
            questions: result[0],
          },
        };
      } else {
        return {
          message: "success",
          data: {
            window: false,
            nextWindowStartTime: currentWindow[0].NextWindowStartTime,
          },
        };
      }
    } catch (error) {
      console.log(error);
      return { err: "Can't retriev questions please try again!" };
    }
  }

  static async adminViewQuestions(windowId) {
    try {
      const [result] = await pool.query(`CALL CurrentWindowQuestions(?)`, [
        windowId,
      ]);
      return { questions: result[0] };
    } catch (error) {
      console.log(error);
      return { err: "Can't retriev questions please try again!" };
    }
  }

  static async updateQuestions(questions, images) {
    console.log(images);
    try {
      await pool.query("START TRANSACTION");
      for (let i = 0; i < questions.length; i++) {
        await pool.query(`CALL UpdateQuestion(?, ?, ?)`, [
          questions[i].id,
          questions[i].question,
          questions[i].value,
        ]);

        //update choice
        let choices = questions[i].choices;
        for (let j = 0; j < choices.length; j++) {
          const choice = choices[j].choice;
          const id = choices[j].id;
          let image = choices[j].image;

          const findImage = images.find(
            (element) =>
              element.fieldname === `questions[${i}][choices][${j}][image]`
          );
          if (findImage) {
            image = findImage.filename;
          }

          await pool.query(`CALL UpdateChoice (?, ?, ?)`, [id, choice, image]);
        }
      }
      await pool.query("COMMIT");
      return { updated: true };
    } catch (error) {
      console.log(error);
      await pool.query("ROLLBACK");
      return { err: "Error while updating a question!", updated: false };
    }
  }
}

module.exports = Questions;
