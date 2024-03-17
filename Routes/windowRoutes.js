const express = require("express");
const {
  getWindows,
  updateWindow,
  deleteWindow
} = require("../Controllers/windowsController");

const router = express.Router();

router.get("/", getWindows);
router.post("/update", updateWindow);
router.delete("/delete", deleteWindow);
module.exports = router;
