const pool = require("../Config/dbConfig");

class FindMatches {
  static async allUserAnswers(windowId, gender) {
    try {
      const [result] = await pool.query(`CALL FindMatches(?, ?)`, [
        windowId,
        gender,
      ]);
      return result[0];
    } catch (error) {
      console.log(error);
      return { err: "Can't load user answers please try again!", error };
    }
  }
}

module.exports = FindMatches;
