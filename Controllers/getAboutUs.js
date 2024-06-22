const path = require("path");
const getAboutUs = async (req, res) => {
  try {
    res
      .status(200)
      .sendFile(path.join(__dirname, "../public/view/aboutUs.html"));
  } catch (error) {
    console.error("Error serving aboutUs.html:", error);
    res.status(500).send("Internal Server Error");
  }
};

module.exports = getAboutUs;
