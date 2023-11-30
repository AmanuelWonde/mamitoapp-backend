const express = require("express");
const http = require("http");
const app = express();
const server = http.createServer(app);
const io = require("socket.io")(server);

const cors = require('cors');

app.use(cors());

io.on('connection', (socket) => {
    console.log(socket.id);

    socket.on('deleted_conversation', (username, id) => {
        console.log(username, id);
        io.emit(username, {
            conversationId: id,
            status: 1025
        });
    });

    socket.on('chat', (status, receiver, result) => {
        console.log(status, result.receiver);
        io.emit(receiver, {
            status: status,
            data: result
        });
    });

});

let port = 3001;

server.listen(port, "0.0.0.0", () => {
    console.log("server started");
});