const loginAdmin = async (req, res) => {
  const email = "amanuel@admin.com";
  const password = "mamito@heruy55";
  if (req.body.email == email && req.body.password == password) {
    return res
      .status(200)
      .json({ message: "user authenticated", email, password });
  } else {
    return res.status(401).json("Invalide credentail");
  }
};

module.exports = { loginAdmin };
