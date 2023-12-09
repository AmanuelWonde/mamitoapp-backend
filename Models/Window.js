const pool = require("../Config/dbConfig");

class Window {
  static async getWindows() {
    try {
      const [result] = await pool.query(`CALL GetWindow()`);
      return { data: result[0] };
    } catch (error) {
      console.log(error);
      return { err: "Faild to load windows" };
    }
  }
  static async updateWindow(windowData) {
    try {
      const { windowId, windowName, startAt, endAt } = windowData;
      const [result] = await pool.query(`CALL UpdateWindow(?, ?, ?, ?)`, [
        windowId,
        windowName,
        startAt,
        endAt,
      ]);
      if (result.affectedRows > 0) {
        return { message: "Window updated successfully." };
      } else {
        return { error: "Faild to update Window please try again" };
      }
    } catch (err) {
      console.log(err);
      return { error: "Faild to update Window please try again" };
    }
  }
}

module.exports = Window;
