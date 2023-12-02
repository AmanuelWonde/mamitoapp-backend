const express = require("express");
const { findMatches } = require("../Controllers/findMatchesController");
const router = express.Router();

router.post("/my-matches", findMatches);
module.exports = router;
