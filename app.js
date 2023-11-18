const express = require('express');
const mysql = require('mysql');

const app = express();
app.use(express.json());

app.use('/user', require('./Routes/user').router);

app.use('/conversation', require('./Routes/conversation').router)

app.use('/chats', require('./Routes/chat').router);

let port = process.env.PORT || 3000;
app.listen(port, () => {
    const debug = require('debug')('basic:server');
    debug(`listening on port ${port}`);
});