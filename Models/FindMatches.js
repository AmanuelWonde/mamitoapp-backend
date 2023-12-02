const pool = require("../Config/dbConfig");

class FindMatches {
  static async allUserAnswers(windowId) {
    try {
      const result = await pool.query(`CALL AllUserAnswers (?)`, [windowId]);
      return result;
    } catch (error) {
      console.log(error);
      return { err: "can't load user answers please try again!", error };
    }
  }
}

module.exports = FindMatches;
