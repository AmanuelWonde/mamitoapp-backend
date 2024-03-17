const fs = require("fs");
const path = require("path");

const deleteImage = (imageName) => {
  const folderPath = "/public/choiceImages";
  const imagePath = path.join(__dirname, folderPath, imageName);

  // Check if the file exists before attempting to delete it
  fs.access(imagePath, fs.constants.F_OK, (err) => {
    if (err) {
      console.error(`The file ${imageName} does not exist.`);
      return {
        imageExist: false,
        deleted: false,
        message: "Can'nt find the image.",
      };
    }

    // File exists, so we can delete it
    fs.unlink(imagePath, (err) => {
      if (err) {
        console.error(`Error deleting ${imageName}: ${err}`);
        return {
          imageExist: false,
          deleted: false,
          message: "Image Exists but faild to delete the image",
        };
      }
      console.log(`${imageName} has been successfully deleted.`);
      return {
        imageExist: true,
        deleted: true,
        message: "Image has been successfully deleted.",
      };
    });
  });
};

module.exports = deleteImage;
