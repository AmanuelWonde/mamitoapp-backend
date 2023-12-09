// express router declaretion
const express = require("express");
const router = express.Router();
const { upload } = require("../Config/multerConfig");

router.post("/signup", require("../Middleware/user/signup"));

router.post("/login", require("../Middleware/user/login"));

router.post("/profileimageupload", (req, res) => {});

module.exports = { router };
