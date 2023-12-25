const ProfileImages = require("../Models/ProfileImages");

const addProfileImage = async (req, res) => {
  try {
    const { userName } = req.body;
    const imagePath = req.file.filename;

    const addImage = await ProfileImages.add(imagePath, userName);
    if (addImage.message) return res.status(201).json(addImage);
    return res
      .status(501)
      .json({ error: "Faild to add profile image  please try again!" });
  } catch (err) {
    console.log(err);
    return res
      .status(501)
      .json({ error: "Faild to add profile image  please try again!" });
  }
};

const viewProfileImage = async (req, res) => {
  try {
    const userName = req.params.userName;
    const images = await ProfileImages.view(userName);
    if (images.message)
      return res
        .status(200)
        .json({ message: images.message, profiles: images.images });

    return res.status(404).json({ error: "Can't find profile images" });
  } catch (err) {
    console.log(err);
    return res.status(501).json({ error: "Faild to load profile images" });
  }
};

const deleteProfileImage = async (req, res) => {
  try {
    const { userName, id } = req.body;
    const result = await ProfileImages.delete(userName, id);
    if (result.message)
      return res.status(201).json({ message: result.message });
    return res.status(404).json({ error: result.error });
  } catch (err) {
    return res
      .status(501)
      .json({ error: "Faild to delte profile image please try again!" });
  }
};

module.exports = { addProfileImage, viewProfileImage, deleteProfileImage };
