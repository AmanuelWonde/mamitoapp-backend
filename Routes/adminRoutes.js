const express = require("express");
const { loginAdmin } = require("../Controllers/adminController");
const { adminViewQuestions } = require("../Controllers/questionController");
const forgotPassword = require("../Controllers/admin/forgotPassword");
const changePassword = require("../Controllers/admin/changePassword");
const router = express.Router();

router.post("/login", loginAdmin);
router.get("/view-window-questions/:windowId", adminViewQuestions);
router.post("/forgot-password", forgotPassword);
router.post("/change-password", changePassword);
module.exports = router;
