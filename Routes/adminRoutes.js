const express = require("express");
const { loginAdmin } = require("../Controllers/adminController");
const { adminViewQuestions } = require("../Controllers/questionController");
const forgotPassword = require("../Controllers/admin/forgotPassword");
const changePassword = require("../Controllers/admin/changePassword");
const additionalWindowData = require("../Controllers/admin/additionalWindowData");
const dashboard = require("../Controllers/admin/dashboard");
const viewWindowData = require("../Controllers/admin/viewWindowData");

const router = express.Router();

router.post("/login", loginAdmin);
router.get("/view-window-questions/:windowId", adminViewQuestions);
router.get("/additional-window-data", additionalWindowData);
router.get("/dashboard", dashboard);
router.get("/view-window-data", viewWindowData);
router.post("/forgot-password", forgotPassword);
router.post("/change-password", changePassword);
module.exports = router;
