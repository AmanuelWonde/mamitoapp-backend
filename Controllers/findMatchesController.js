const FindMatches = require("../Models/FindMatches");
const findUserMatches = require("../helpers/findUserMatches");
const Answers = require("../Models/Answers");

const findMatches = async (req, res) => {
  try {
    const { windowId, userName, myAnswers } = req.body;
    const allUserAnswers = await FindMatches.allUserAnswers(windowId);

    console.log("users who answerd the currect window", allUserAnswers);

    const yourMatches = findUserMatches(myAnswers, allUserAnswers);
    await Answers.addAnswers(windowId, userName, myAnswers);

    return res
      .status(200)
      .json({ message: "Your matches", matches: yourMatches });
  } catch (err) {
    console.log(err);
    return res.status(501).json({
      error: "Error while matching user please try again",
    });
  }
};
module.exports = { findMatches };
