const User = require("../../Models/User");

const getUserDetail = async (req, res) => {
  const { username } = req.params;
  try {
    const { success, profileData, message } = await User.getUserProfileData(
      username
    );
    if (!success) return res.status(400).json({ message });

    let { password, phone, ...extracted } = profileData;
    return res.status(200).json({
      message: "User profile getted successfully.",
      data: extracted,
    });
  } catch (error) {
    console.log(error);

    return res
      .status(500)
      .json({ error: "Failed to retrieve user detail please try later" });
  }
};

module.exports = getUserDetail;
