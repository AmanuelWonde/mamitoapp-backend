const express = require("express");
const {
  addSampleVerifyImage,
  viewSampleVerifyImages,
  addUserVerificationImage,
  viewUserVerificationImages,
  validateUser,
} = require("../Controllers/userVerificationController");
const { upload } = require("../Config/multerConfig");
const { route } = require("./questionRoutes");
const router = express.Router();

router.post(
  "/add-sample-verification-image",
  upload.single("image"),
  addSampleVerifyImage
);

router.get("/view-sample-images", viewSampleVerifyImages);

router.post(
  "/verify-my-account",
  upload.single("image"),
  addUserVerificationImage
);

router.get("/view-verification-images", viewUserVerificationImages);
router.post("/validate-user", validateUser);
module.exports = router;
