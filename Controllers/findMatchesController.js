const FindMatches = require("../Models/FindMatches");
const findUserMatches = require("../helpers/match/findUserMatches");
const Answers = require("../Models/Answers");
const User = require("../Models/User");

const findMatches = async (req, res) => {
  try {
    const { windowId, userName, answers, mood } = req.body;
    const { success, profileData, message } = await User.getUserProfileData(
      userName
    );

    if (!success) return res.status(400).json({ message });

    const allUserAnswers = await FindMatches.allUserAnswers(windowId);

    req.body.gender = profileData.gender;
    req.body.verified = profileData.verified;
    req.body.birthdate = profileData.birthdate;
    req.body.religion = profileData.religion;

    console.log(req.body);
    const yourMatches = findUserMatches(req.body, allUserAnswers);

    await Answers.addAnswers(windowId, userName, answers, mood);

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
