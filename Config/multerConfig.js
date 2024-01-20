const multer = require("multer");
const path = require("path");

// Function to generate storage based on directory
const generateStorage = (directory) => {
  return multer.diskStorage({
    destination: (req, file, cb) => {
      cb(null, path.join(__dirname, `../public/${directory}`));
    },
    filename: (req, file, cb) => {
      cb(
        null,
        file.fieldname + "-" + Date.now() + path.extname(file.originalname)
      );
    },
  });
};

// Function to upload to specific directory
const upload = (directory) => {
  return multer({ storage: generateStorage(directory) }); // Change 'image' to your field name
};

module.exports = { upload };