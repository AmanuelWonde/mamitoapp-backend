const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use("/public", express.static("public"));

app.use(bodyParser.json());
app.use(express.static("./public"));
app.use("/user", require("./Routes/user").router);
app.use("/conversation", require("./Routes/conversation").router);
app.use("/chats", require("./Routes/chat").router);
app.use("/questions", require("./Routes/questionRoutes"));
app.use("/answers", require("./Routes/answerRoutes"));
app.use("/match", require("./Routes/matchRoutes"));
app.use("/verify-user", require("./Routes/userVerificationRoutes"));
app.use("/admin", require("./Routes/adminRoutes"));

app.listen(port, () => {
  console.log("listening on port 3000");
});
