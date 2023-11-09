const express = require('express');
const mysql = require('mysql');

const app = express();
app.use(express.json());

const UserRegRouter = require('./Routes/UserReg').router;
app.use('/user', UserRegRouter);


let port = process.env.PORT || 3000;
app.listen(port, () => {
    const debug = require('debug')('basic:server');
    debug(`listening on port ${port}`)
});