const express = require("express");
const {
  addQuestions,
  viewQuestions,
} = require("../Controllers/questionController");
const router = express.Router();

router.post("/add", addQuestions);
router.get("/:windowId", viewQuestions);

module.exports = router;
