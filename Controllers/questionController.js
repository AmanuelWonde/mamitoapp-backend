const Questions = require("../Models/Questions");
const User = require("../Models/UserProfile");
const getAge = require("../utils/getAge");

const addQuestions = async (req, res) => {
  try {
    const { questions, windowName, startAt, endAt, mood, minAge, maxAge } =
      req.body;

    const images = req.files;

    const addQuestions = await Questions.addQuestions(
      questions,
      images,
      windowName,
      startAt,
      endAt,
      mood,
      minAge,
      maxAge
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
    const { username, mood } = req.query;
    const { profileData } = await User.getUserProfileData(username);
    const age = getAge(profileData.birthdate);

    const getQuestions = await Questions.viewQuestions(
      username,
      profileData.gender,
      mood,
      age
    );

    if (getQuestions.err)
      return res.status(500).json({ error: getQuestions.err });

    return res.status(200).json(getQuestions);
  } catch (err) {
    return res
      .status(500)
      .json({ error: "Internal server error please try again!" });
  }
};

const adminViewQuestions = async (req, res) => {
  try {
    const windowId = req.params.windowId;
    const getQuestions = await Questions.adminViewQuestions(windowId);

    if (getQuestions.err)
      return res.status(500).json({ error: getQuestions.err });

    return res.status(200).json(getQuestions);
  } catch (err) {
    return res
      .status(500)
      .json({ error: "Internal server error please try again!" });
  }
};

const updateQuestions = async (req, res) => {
  try {
    const updateQuestions = await Questions.updateQuestions(
      req.body.questions,
      req.files
    );
    if (updateQuestions.updated)
      return res
        .status(200)
        .json({ message: "updated successfully.", updated: true });
    else {
      return res.status(501).json({
        message: "can't update questions please try again!",
        updated: false,
      });
    }
  } catch (error) {
    return res.status(501).json({
      message: "can't update questions please try again!",
      updated: false,
    });
  }
};

module.exports = {
  addQuestions,
  viewQuestions,
  adminViewQuestions,
  updateQuestions,
};
