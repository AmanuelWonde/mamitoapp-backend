const express = require("express");
const mysql = require("mysql");

const app = express();
app.use(express.json());

const port = 4000;
const UserRegRouter = require("./Routes/UserReg").router;
const questions = require("./Routes/questionRoutes");
const answers = require("./Routes/answerRoutes");
app.use("/user", UserRegRouter);
app.use("/questions", questions);
app.use("/answers", answers);
app.listen(port, () => {
  const debug = require("debug")("basic:server");
  debug(`listening on port ${port}`);
  console.log("server is running");
});
