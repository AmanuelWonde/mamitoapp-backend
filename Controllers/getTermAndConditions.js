const path = require("path");

const getTermAndConditions = async (req, res) => {
  try {
    res
      .status(200)
      .sendFile(path.join(__dirname, "../public/view/termAndConditions.html"));
  } catch (error) {
    console.error("Error serving deleteAccount.html:", error);
    res.status(500).send("Internal Server Error");
  }
};
module.exports = getTermAndConditions;
