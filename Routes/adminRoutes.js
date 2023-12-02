const express = require("express");
const { loginAdmin } = require("../Controllers/adminController");
const router = express.Router();

router.post("/login", loginAdmin);
module.exports = router;
