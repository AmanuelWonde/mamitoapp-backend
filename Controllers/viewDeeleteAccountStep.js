const path = require("path");
const viewDeleteAccountStep = async (req, res) => {
  try {
    res
      .status(200)
      .sendFile(path.join(__dirname, "../public/view/deleteAccount.html"));
  } catch (error) {
    console.error("Error serving deleteAccount.html:", error);
    res.status(500).send("Internal Server Error");
  }
};

module.exports = viewDeleteAccountStep;
