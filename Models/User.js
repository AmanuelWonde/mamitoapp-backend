const pool = require("../Config/dbConfig");

class User {
  static async getUserProfileData(username) {
    try {
      const [userProfileData] = await pool.query(`CALL UserProfileData(?)`, [
        username,
      ]);

      if (!userProfileData[0].length)
        return { success: false, message: "Invalide username." };

      return { success: true, profileData: userProfileData[0][0] };
    } catch (error) {
      console.log(error);
      return { success: false };
    }
  }
}

module.exports = User;
