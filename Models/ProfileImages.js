const pool = require("../Config/dbConfig");
class ProfileImages {
  static async add(image, username) {
    try {
      const [addProfile] = await pool.query(`CALL AddProfileImage(?, ?)`, [
        image,
        username,
      ]);
      console.log(addProfile.affectedRows);
      if (addProfile.affectedRows)
        return { message: "profile image added successfully." };
      return { error: "Faild to add profile image!" };
    } catch (err) {
      console.log(err);
      return { error: "can't add profile image please try again.", err };
    }
  }

  static async view(username) {
    try {
      const [images] = await pool.query(`CALL ViewProfileImages(?)`, [
        username,
      ]);
      if (images) return { message: "Your profile images", images: images[0] };
      return { error: "Can't find profile images" };
    } catch (err) {
      console.log(err);
      return { error: "Can't find profile images" };
    }
  }

  static async delete(username, id) {
    try {
      const [result] = await pool.query(`CALL DeleteProfileImage(?, ?)`, [
        username,
        id,
      ]);
      if (result.affectedRows) return { message: "image deleted successfully" };
      return { error: "Can't fint the image you'r looking for" };
    } catch (err) {
      console.log(err);
      return { error: "Can't fint the image you'r looking for" };
    }
  }
}
module.exports = ProfileImages;
