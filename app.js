const express = require('express');
const mysql = require('mysql');
const multer = require('multer');

const app = express();

let port = process.env.PORT || 3000;

app.listen(port, () => {
    const debug = require('debug')('basic:server');
    debug(`listening on port ${port}`)
});