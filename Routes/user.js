// express router declaretion
const express = require("express");
const router = express.Router();
const auth = require('../Middleware/auth/auth');

const { upload } = require("../Config/multerConfig");
const {
  addProfileImage,
  deleteProfileImage,
  viewProfileImage,
} = require("../Controllers/profileImageController");

router.post("/signup", require("../Middleware/user/signup"));

router.post("/login", require("../Middleware/user/login"));

router.put("/update", auth, require("../Middleware/user/update"));

router.post("/rcvfill", auth, require("../Middleware/user/passwordRecoveryQuestionsFill"));

router.put("/changepassword", auth, require("../Middleware/user/changepassword"));

router.get("/getrcvqst", auth, require("../Middleware/user/getRcvQst"));

router.put("/forgotpassword", require("../Middleware/user/forgotpassword"));

router.post(
  "/profileimageupload", auth,
  upload("profileImages").single("profileImage"),
  addProfileImage
);

router.post("/deleteprofileimage", auth, deleteProfileImage);
router.get("/viewprofileimages/:userName", auth, viewProfileImage);

module.exports = { router };
