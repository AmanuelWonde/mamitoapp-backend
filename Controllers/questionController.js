const Questions = require("../Models/Questions");

const addQuestions = async (req, res) => {
  try {
    const [questions] = req.body;
    const addQuestions = await Questions.addQuestions(questions);
    if (addQuestions.err)
      return res.status(500).json({ error: addQuestions.err });
    return res.status(201).json({ message: addQuestions.message });
  } catch (error) {
    return res
      .status(500)
      .json({ err: "Internal server eror please try again!" });
  }
};

const viewQuestions = async (req, res) => {
  try {
    const { windowId } = req.body;
    const getQuestions = await Questions.viewQuestions(windowId);
    if (getQuestions.err)
      return res.status(500).json({ error: getQuestions.err });
    return res.status(200).json({ message: getQuestions.message });
  } catch (err) {
    return res
      .status(500)
      .json({ error: "Internal server error please try again!" });
  }
};

module.exports = { addQuestions, viewQuestions };
