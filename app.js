const express = require("express");
const http = require("http");
const bodyParser = require("body-parser");
const app = express();
const server = http.createServer(app);
const io = require("socket.io")(server);
const port = 3000;

app.use(bodyParser.json());
app.use("/user", require("./Routes/user").router);
app.use("/conversation", require("./Routes/conversation").router);
app.use("/chats", require("./Routes/chat").router);
app.use("/questions", require("./Routes/questionRoutes"));
app.use("/answers", require("./Routes/answerRoutes"));
app.use("/match", require("./Routes/matchRoutes"));
io.on("connection", (socket) => {});

server.listen(port, "0.0.0.0", () => {
  console.log("server started");
});
