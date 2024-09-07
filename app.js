const express = require("express");
const app = express();
const http = require("http");
const server = http.createServer(app);
require('dotenv').config();

const bodyParser = require("body-parser");
const cors = require("cors");

const { status, responseInstance } = require("./Models/response");

// express configurations
app.use(cors());
app.use(bodyParser.json());
app.use("/public", express.static("public"));
app.use(express.static("./public"));

// WebSocket Configurations
const io = require("socket.io")(server, {
  cors: {
    origin: "*",
  },
});

io.on("connection", (socket) => {
  console.log(socket.id);
  socket.on("typing", (data) => {
    console.log(data);
    io.mit(data.receiver, new responseInstance(new status(1301), data));
  });
});

const fcm = require('firebase-admin');
const service_account = require(`./${process.env.firebase_sdk}`);
fcm.initializeApp({
    credential: fcm.credential.cert(service_account)
});

app.use("/app-info", require("./Routes/appInfo"));
app.use("/user", require("./Routes/user").router);
app.use("/conversation", require("./Routes/conversation").router);
app.use("/chats", require("./Routes/chat").router);
app.use("/questions", require("./Routes/questionRoutes"));
app.use("/answers", require("./Routes/answerRoutes"));
app.use("/match", require("./Routes/matchRoutes"));
app.use("/verify-user", require("./Routes/userVerificationRoutes"));
app.use("/admin", require("./Routes/adminRoutes"));
app.use("/windows", require("./Routes/windowRoutes"));

server.listen(3000, "0.0.0.0", () => {
  console.log("server started at localhost:3000");
});

module.exports = { io, fcm };
