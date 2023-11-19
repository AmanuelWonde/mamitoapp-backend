// Assuming Answers model exists and has a method addAnswer
const Answers = require("../Models/Answers"); // Import your Answers model

const addAnswer = async (req, res) => {
  try {
    const answers = req.body;

    const addedAnswer = await Answers.addAnswer(answers);

    if (addedAnswer.error)
      return res.status(500).json({ message: "Failed to add answer" });

    return res.status(201).json({ message: addAnswer.message });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ err: "Internal server error" });
  }
};

module.exports = {
  addAnswer,
};
