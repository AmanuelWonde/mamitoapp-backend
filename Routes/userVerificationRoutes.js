const express = require("express");
const {
  addSampleVerifyImage,
  viewSampleVerifyImages,
  addUserVerificationImage,
} = require("../Controllers/userVerificationController");
const { upload } = require("../Config/multerConfig");
const router = express.Router();

router.post(
  "/add-verification-sample-image",
  upload.single("image"),
  addSampleVerifyImage
);

router.get("/view-sample-images", viewSampleVerifyImages);

router.post(
  "/verify-my-account",
  upload.single("image"),
  addUserVerificationImage
);
module.exports = router;
