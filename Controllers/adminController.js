const fs = require('fs');
const bcrypt = require('bcryptjs');

const loginAdmin = (req, res) => {
  const email = "amanuel@admin.com";
  const password = fs.readFileSync('.admin_password', 'utf-8');
        // "mamito@heruy55";

  if (req.body.email == email && bcrypt.compareSync(req.body.password, password)) {
    return res
      .status(200)
      .json({ message: "user authenticated", email });
  } else {
    return res.status(401).json("Invalide credentail");
  }
};

module.exports = { loginAdmin };
