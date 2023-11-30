// Assuming Answers model exists and has a method addAnswer
const Answers = require("../Models/Answers"); // Import your Answers model

const addAnswer = async (req, res) => {
  try {
    const { windowId, userName, answers } = req.body;
    const addAnswers = await Answers.addAnswers(windowId, userName, answers);

    if (addAnswers.error)
      return res.status(500).json({ error: "Failed to add answers" });

    return res.status(201).json({ message: addAnswers.message });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ err: "Internal server error" });
  }
};

module.exports = {
  addAnswer,
};
