const bcrypt = require("bcryptjs");
const fs = require("fs").promises;

module.exports = async (req, res) => {
  const { old_password, new_password } = req.body;

  try {
    // Read the current password from the file
    const password = await fs.readFile(".admin_password", "utf-8");
    console.log(password);

    // Compare the provided old password with the stored password
    const isMatch = await bcrypt.compare(old_password, password);

    if (!isMatch) {
      return res.status(403).json("incorrect old password");
    }

    // Hash the new password
    const encPassword = await bcrypt.hash(new_password, 10);

    // Write the new hashed password to the file
    await fs.writeFile(".admin_password", encPassword, "utf-8");

    return res.status(200).json({ success: true });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "error while processing request" });
  }
};
