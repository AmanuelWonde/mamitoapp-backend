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

router.put("/update", require("../Middleware/user/update"));

router.post(
  "/rcvfill",
  require("../Middleware/user/passwordRecoveryQuestionsFill")
);

router.put("/changepassword", require("../Middleware/user/changepassword"));

router.get("/getrcvqst", require("../Middleware/user/getRcvQst"));

router.put("/forgotpassword", require("../Middleware/user/forgotpassword"));

router.post(
  "/profileimageupload",
  upload("profileImages").single("profileImage"),
  addProfileImage
);

router.post("/deleteprofileimage", deleteProfileImage);
router.get("/viewprofileimages/:userName", viewProfileImage);

module.exports = { router };
