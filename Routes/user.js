// express router declaretion
const express = require("express");
const router = express.Router();
const auth = require("../Middleware/auth/auth");

const { upload } = require("../Config/multerConfig");
const {
  addProfileImage,
  deleteProfileImage,
  viewProfileImage,
} = require("../Controllers/profileImageController");

const getUserDetail = require("../Controllers/user/getUserDetail");

router.post("/signup", require("../Middleware/user/signup"));

router.post("/login", require("../Middleware/user/login"));

router.put("/update", auth, require("../Middleware/user/update"));

router.put("/updateverified", require("../Middleware/user/updateVerfied"));

router.post(
  "/rcvfill",
  auth,
  require("../Middleware/user/passwordRecoveryQuestionsFill")
);

router.put("/changepassword", require("../Middleware/user/changepassword"));

router.post("/getrcvqst", require("../Middleware/user/getRcvQst"));

router.post(
  "/profiledatapush",
  auth,
  require("../Middleware/user/profileDataPush")
);

router.get("/profile-detail/:username", getUserDetail);
router.get("/getprofiledata", require("../Middleware/user/getProfileData"));

router.put("/forgotpassword", require("../Middleware/user/forgotpassword"));

router.post(
  "/profileimageupload",
  auth,
  upload("profileImages").single("profileImage"),
  addProfileImage
);

router.post("/deleteprofileimage", auth, deleteProfileImage);
router.get("/viewprofileimages/:userName", auth, viewProfileImage);
router.get(
  "/view/how-to-delete-account",
  require("../Controllers/viewDeeleteAccountStep")
);

module.exports = { router };
