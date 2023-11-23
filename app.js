const express = require("express");
const app = express();
const port = 4000;

app.use(express.json());
app.use("/questions", require("./Routes/questionRoutes"));
app.use("/answers", require("./Routes/answerRoutes"));

app.listen(port, () => {
  const debug = require("debug")("basic:server");
  debug(`listening on port ${port}`);
  console.log("server is running");
});
