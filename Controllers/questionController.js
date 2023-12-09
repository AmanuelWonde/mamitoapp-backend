const Questions = require("../Models/Questions");

const addQuestions = async (req, res) => {
  try {
    const questions = req.body.questions;
    const windowName = req.body.windowName;
    const startAt = req.body.startAt;
    const endAt = req.body.endAt;
    const images = req.files;

    // console.log(questions);

    const addQuestions = await Questions.addQuestions(
      questions,
      images,
      windowName,
      startAt,
      endAt
    );

    if (addQuestions.err) {
      // console.log(addQuestions.err);
      return res.status(500).json({ error: addQuestions.err });
    }
    // console.log(addQuestions.message);
    return res.status(201).json({ message: addQuestions.message });
  } catch (error) {
    return res
      .status(500)
      .json({ err: "Internal server eror please try again!", error });
  }
};

const viewQuestions = async (req, res) => {
  try {
    const windowId = req.params.windowId;
    // console.log(windowId);
    const getQuestions = await Questions.viewQuestions(windowId);
    if (getQuestions.err)
      return res.status(500).json({ error: getQuestions.err });
    return res
      .status(200)
      .json({ message: getQuestions.message, questions: getQuestions.result });
  } catch (err) {
    return res
      .status(500)
      .json({ error: "Internal server error please try again!" });
  }
};

module.exports = { addQuestions, viewQuestions };
