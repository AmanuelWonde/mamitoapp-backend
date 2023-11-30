// express router declaretion

const express = require('express');
const router = express.Router();

// module imports

const auth = require('../Middleware/auth/auth');

// api's

router.post('/sendchat', auth, require('../Middleware/chat/sendchat'));

router.put('/editchat', auth, require('../Middleware/chat/editchat'));

router.delete('/deletechat', auth, require('../Middleware/chat/deletechat'));

router.get('/getnewchat', auth, require('../Middleware/chat/getnewchat'));

router.get('/getedits', auth, require('../Middleware/chat/getedits'));

router.get('/getchat', auth, require('../Middleware/chat/getchat'));

module.exports = { router };