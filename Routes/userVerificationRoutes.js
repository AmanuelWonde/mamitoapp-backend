const express = require("express");
const {
  addSampleVerifyImage,
  viewSampleVerifyImages,
  addUserVerificationImage,
  viewUserVerificationImages,
  validateUser,
} = require("../Controllers/userVerificationController");
const { upload } = require("../Config/multerConfig");
const router = express.Router();

router.post(
  "/add-sample-verification-image",
  upload("sampleVerificationImages").single("image"),
  addSampleVerifyImage
);

router.get("/view-sample-images", viewSampleVerifyImages);

router.post(
  "/verify-my-account",
  upload("verificationImages").single("image"),
  addUserVerificationImage
);

router.get("/view-verification-images", viewUserVerificationImages);
router.post("/validate-user", validateUser);
module.exports = router;
