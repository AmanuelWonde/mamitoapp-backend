const express = require("express");
const { upload } = require("../Config/multerConfig");
const {
  addQuestions,
  viewQuestions,
  updateQuestions,
} = require("../Controllers/questionController");
const router = express.Router();

router.post("/add", upload("choiceImages").any(), addQuestions);
router.post("/update", upload("choiceImages").any(), updateQuestions);
router.get("/:username", viewQuestions);

module.exports = router;
