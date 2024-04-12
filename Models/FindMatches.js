const pool = require("../Config/dbConfig");

class FindMatches {
  static async allUserAnswers(windowId) {
    try {
      const [result] = await pool.query(`CALL FindMatches(?)`, [windowId]);
      console.log("Users from the database in the given window Id", result);
      return result[0];
    } catch (error) {
      console.log(error);
      return { err: "can't load user answers please try again!", error };
    }
  }
}

module.exports = FindMatches;
