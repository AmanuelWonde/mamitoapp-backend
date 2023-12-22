const pool = require("../Config/dbConfig");
class User {
  static async addProfileImage(image, username) {
    try {
      const [addProfile] = await pool.query(`CALL AddProfileImage(?, ?)`, [
        image,
        username,
      ]);
      console.log(addProfile);
      return { message: "profile image added successfully." };
    } catch (err) {
      console.log(err);
      return { error: "can't add profile image please try again.", err };
    }
  }
}

module.exports = User;
