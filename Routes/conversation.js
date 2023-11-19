// express router declaretion
const express = require('express');
const router = express.Router();

// module imports
const auth = require('../Middleware/auth/auth')

// api's
router.post('/start', auth, require('../Middleware/conversation/startConversation'));
router.delete('/delete', auth, require('../Middleware/conversation/deleteConversation'));

module.exports = { router };