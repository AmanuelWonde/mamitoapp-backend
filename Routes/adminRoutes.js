const express = require("express");
const { loginAdmin } = require("../Controllers/adminController");
const { adminViewQuestions } = require("../Controllers/questionController");
const router = express.Router();

router.post("/login", loginAdmin);
router.get("/view-window-questions/:windowId", adminViewQuestions);
module.exports = router;
