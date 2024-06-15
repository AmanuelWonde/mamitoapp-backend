const bcrypt = require('bcryptjs');
const fs = require('fs');

module.exports = async (req, res) => {
  let { old_password, new_password } = req.body;
  let password = fs.readFileSync('.admin_password', 'utf-8');
  console.log(password);

  if (!bcrypt.compareSync(old_password, password)) {
    return res.status(403).json('incorrect old password');
  };

  try {
    let encPassword = bcrypt.hashSync(new_password, 10);
    fs.writeFile('.admin_password', encPassword, 'utf-8', () => {});
  } catch(error) {
    console.error(error);
    return res.status(500).json({ error: "error while processing request" });
  }

  return res.status(200).json({ succss: true })
}
