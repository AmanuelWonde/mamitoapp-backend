const pool = require("../Config/dbConfig");

class FindMatches {
  static async allUserAnswers(windowId) {
    try {
      const [result] = await pool.query(`CALL FindMatches(?)`, [windowId]);
      return result[0];
    } catch (error) {
      console.log(error);
      return { err: "Can't load user answers please try again!", error };
    }
  }
}

module.exports = FindMatches;
