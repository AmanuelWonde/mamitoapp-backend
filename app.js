const express = require('express');
let http = require('http');

const app = express();
const server = http.createServer(app);
const io = require('socket.io')(server);

app.use(express.json());

app.use('/user', require('./Routes/user').router);

app.use('/conversation', require('./Routes/conversation').router)

app.use('/chats', require('./Routes/chat').router);

app.use("/questions", require("./Routes/questionRoutes"));

app.use("/answers", require("./Routes/answerRoutes"));

io.on("connection", (socket) => {

})

let port = process.env.PORT || 3000;

server.listen(port, "0.0.0.0", () => {
  console.log("server started");
  app.listen(port, () => {
    const debug = require("debug")("basic:server");
    debug(`listening on port ${port}`);
    console.log("server is running");
  })
});