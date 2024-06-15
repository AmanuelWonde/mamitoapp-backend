const fs = require('fs');
const bcrypt = require('bcryptjs');
const emailto = require('../../utils/email');

const { Random, MersenneTwister19937 } = require('random-js');

const engine = MersenneTwister19937.autoSeed();

const random = new Random(engine);

module.exports = async (req, res) => {
  const newPassword = random.integer(1000000, 9999999);
  let encPassword = bcrypt.hashSync(newPassword.toString());

  try {
    fs.writeFile('.admin_password', encPassword, 'utf-8', () => {});
  } catch(error) {
    console.error(error);
    return res.status(500).json({ error: "error while processing request" });
  }
  emailto('abelrighthere@gmail.com', 'forgot password', "new password", `<h1>${newPassword}</h1>`);
  res.status(200).json({ success: true });
}
