const express = require("express");
const {
  getWindows,
  updateWindow,
} = require("../Controllers/windowsController");
const router = express.Router();

router.get("/", getWindows);
router.post("/update", updateWindow);
module.exports = router;
