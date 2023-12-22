// express router declaretion
const express = require("express");
const router = express.Router();
const { upload } = require("../Config/multerConfig");

router.post("/signup", require("../Middleware/user/signup"));

router.post("/login", require("../Middleware/user/login"));

router.put("/update", require("../Middleware/user/update"));

router.post("/rcvfill", require("../Middleware/user/passwordRecoveryQuestionsFill"));

router.put('/changepassword', require("../Middleware/user/changepassword"));

router.get('/getrcvqst', require('../Middleware/user/getRcvQst'));

router.put("/forgotpassword", require("../Middleware/user/forgotpassword"));





// router.post("/profileimageupload", (req, res) => { });

module.exports = { router };
