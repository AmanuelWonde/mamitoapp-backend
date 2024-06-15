const fs = require('fs');
const bcrypt = require('bcryptjs');

const loginAdmin = async (req, res) => {
  const email = "amanuel@admin.com";
  const password = fs.readSync('.admin_password', 'utf-8');
        // "mamito@heruy55";

  if (req.body.email == email && bcrypt.compareSync(req.body.password, password)) {
    return res
      .status(200)
      .json({ message: "user authenticated", email, password });
  } else {
    return res.status(401).json("Invalide credentail");
  }
};

module.exports = { loginAdmin };
