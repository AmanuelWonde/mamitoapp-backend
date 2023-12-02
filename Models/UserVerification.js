const pool = require("../Config/dbConfig");

class UserVerification {
  static async addSampleVerifyImage(img, gender) {
    try {
      await pool.query(`CALL InsertSampleImage(?, ?)`, [img, gender]);
      return { message: "Image Sample Inserted Successfully" };
    } catch (error) {
      console.log(error);
      return { err: "Faild to insert sample images!" };
    }
  }

  static async viewSampleVerifyImages(gender) {
    try {
      const [result] = await pool.query(`CALL GetSampleImages(?)`, [gender]);
      return result[0];
    } catch (error) {
      console.log(error);
      return { err: "Can't retriev sample images please try again." };
    }
  }

  static async addUserVerificationImage(image, sampleImageId, username) {
    try {
      await pool.query(`CALL AddVerificationImage(?, ?, ?)`, [
        image,
        sampleImageId,
        username,
      ]);
      return { message: "Image added successfully!" };
    } catch (error) {
      console.log(error);
      return { err: "can't add image please try again!" };
    }
  }
}

module.exports = UserVerification;
