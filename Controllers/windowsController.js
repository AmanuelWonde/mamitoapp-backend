const Window = require("../Models/Window");

const getWindows = async (req, res) => {
  try {
    const result = await Window.getWindows();
    return res.status(200).json({ data: result });
  } catch (err) {
    return res.status(501).json({ error: "Faild to load questions" });
  }
};

const updateWindow = async (req, res) => {
  try {
    const result = await Window.updateWindow(req.body);
    if (result.message)
      return res.status(201).json({ message: result.message });

    return res.status(501).json({ error: result.error });
  } catch (error) {
    console.log(error);
    return res.status(501).json({ error: "Failed to update window!" });
  }
};

const deleteWindow = async (req, res) => {
  try {
    const result = await Window.deleteWindow(req.body.id);
    if (result.message)
      return res.status(200).json({ message: result.message });

    console.log(result);
    return res.status(501).json({ error: "Failed to delete window! "});
  } catch (error) {
    console.log(error);
    return res.status(501).json({ error: "Failed to delete2 window! "});
  }
}

module.exports = { getWindows, updateWindow, deleteWindow };
