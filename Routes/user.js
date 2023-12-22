// express router declaretion
const express = require("express");
const router = express.Router();
const { upload } = require("../Config/multerConfig");
const {
  addProfileImage,
  deleteProfileImage,
  viewProfileImage,
} = require("../Controllers/profileImageController");

router.post("/signup", require("../Middleware/user/signup"));

router.post("/login", require("../Middleware/user/login"));

router.post(
  "/profileimageupload",
  upload("profileImages").single("profileImage"),
  addProfileImage
);

router.post("/deleteprofileimage", deleteProfileImage);
router.get("/viewprofileimages/:userName", viewProfileImage);
module.exports = { router };
