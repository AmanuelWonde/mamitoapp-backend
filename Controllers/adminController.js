const fs = require("fs").promises;
const bcrypt = require("bcryptjs");

const loginAdmin = async (req, res) => {
  try {
    const email = "amanuel@admin.com";
    const password = await fs.readFile(".admin_password", "utf-8");

    const passwordMatch = await bcrypt.compare(req.body.password, password);

    if (req.body.email === email && passwordMatch) {
      return res.status(200).json({ message: "User authenticated", email });
    } else {
      return res.status(401).json({ message: "Invalid credentials" });
    }
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Server error", error: error.message });
  }
};

module.exports = { loginAdmin };
