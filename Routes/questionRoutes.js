const express = require("express");
const { upload } = require("../Config/multerConfig");

const {
  addQuestions,
  viewQuestions,
} = require("../Controllers/questionController");
const router = express.Router();

router.post("/add", upload("choiceImages").any(), addQuestions);
router.get("/:username", viewQuestions);

module.exports = router;
