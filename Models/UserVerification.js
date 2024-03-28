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
      console.log(result);
      return result[0];
    } catch (error) {
      console.log(error);
      return { err: "Can't retriev sample images please try again." };
    }
  }

  static async deleteSampleImage(id) {
    try {
      await pool.query(`CALL DeleteSampleImage(?)`, [id]);
      return { deleted: true };
    } catch (error) {
      return { deleted: false };
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
  static async viewUserVerificationImages() {
    try {
      const [result] = await pool.query(`CALL ViewUserVerificationImages()`);
      if (result[0])
        return { message: "User verificationo images", data: result[0] };
      return { errror: "Faild to load verification images!" };
    } catch (err) {
      return { errror: "Faild to load verification images!" };
    }
  }
  static async validateUser(status, username, sampleImageId) {
    try {
      const result = await pool.query(`CALL ValidateUserImages(?, ?, ?)`, [
        status,
        username,
        sampleImageId,
      ]);
      console.log(result);
      if (result[0].affectedRows)
        return { message: "user validate successfully" };

      return { error: "Faild to validate user please try again!" };
    } catch (err) {
      console.log(err);
      return { error: "Faild to validate user please try again!" };
    }
  }
}

module.exports = UserVerification;
