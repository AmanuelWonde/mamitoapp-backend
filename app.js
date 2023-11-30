const express = require("express");
const app = express();

app.use(express.json());

app.use("/user", require("./Routes/user").router);

app.use("/conversation", require("./Routes/conversation").router);

app.use('/chats', require('./Routes/chat').router);

app.use("/questions", require("./Routes/questionRoutes"));

app.use("/answers", require("./Routes/answerRoutes"));

let port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log('listening on port 3000')
})