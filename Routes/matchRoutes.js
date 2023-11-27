const express = require("express");
const { getMatches } = require("../Controllers/getMatchesController");
const router = express.Router();

router.post("/my-matches", getMatches);
module.exports = router;
