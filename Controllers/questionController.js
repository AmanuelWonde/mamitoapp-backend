const Questions = require("../Models/Questions");

const addQuestions = async (req, res) => {
  try {
    const questions = req.body.questions;
    const windowName = req.body.windowName;
    const startAt = req.body.startAt;
    const endAt = req.body.endAt;
    const images = req.files;

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
    console.log(error);
    return res
      .status(500)
      .json({ err: "Internal server eror please try again!", error });
  }
};

const viewQuestions = async (req, res) => {
  try {
    const username = req.params.username;
    const getQuestions = await Questions.viewQuestions(username);

    if (getQuestions.err)
      return res.status(500).json({ error: getQuestions.err });

    return res.status(200).json(getQuestions);
  } catch (err) {
    return res
      .status(500)
      .json({ error: "Internal server error please try again!" });
  }
};

module.exports = { addQuestions, viewQuestions };
