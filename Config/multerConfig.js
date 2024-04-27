const multer = require("multer");
const path = require("path");

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

const upload = (directory) => {
  return multer({ storage: generateStorage(directory) });
};

module.exports = { upload };
