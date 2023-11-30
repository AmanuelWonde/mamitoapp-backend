const GetMatches = require("../Models/GetMatches");
const findUserMatches = require("../services/matching/getMatches");
const Answers = require("../Models/Answers");

const getMatches = async (req, res) => {
  try {
    const { windowId, userName, answers } = req.body;
    const allUserAnswers = await GetMatches.allUserAnswers(windowId);

    const yourMatches = findUserMatches(answers, allUserAnswers);
    await Answers.addAnswers(windowId, userName, answers);

    console.log(yourMatches);
    return res
      .status(200)
      .json({ message: "user matches", matches: yourMatches });
  } catch (error) {
    console.log(error);
  }
};
module.exports = { getMatches };
// if a user fails to get a matche in a window why do we save his answers
