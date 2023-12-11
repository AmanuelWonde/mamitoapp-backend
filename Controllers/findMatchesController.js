const FindMatches = require("../Models/FindMatches");
const findUserMatches = require("../services/matching/findUserMatches");
const Answers = require("../Models/Answers");

const findMatches = async (req, res) => {
  try {
    const { windowId, userName, myAnswers } = req.body;
    const allUserAnswers = await FindMatches.allUserAnswers(windowId);

    const yourMatches = findUserMatches(myAnswers, allUserAnswers);
    await Answers.addAnswers(windowId, userName, myAnswers);

    return res
      .status(200)
      .json({ message: "your matches", matches: yourMatches });
  } catch (err) {
    console.log(err);
    return res.status.json({
      error: "error while matching user please try again",
    });
  }
};
module.exports = { findMatches };
// if a user fails to get a matche in a window why do we save his answers
