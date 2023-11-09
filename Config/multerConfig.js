const multer = require('multer');

const storage = multer.diskStorage({
    destination: '../Public/profile-pictures',
    filename: (req, res, cb) => {
        cb(null, req.body.username)
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 2000000 },
    fileFilter: function (req, file, cb) {
        const filetypes = /jpeg|jpg|png|gif/

        const extname = filetypes.test(path.extname(file.originalname));
        const mimetypes = filetypes.test(file.mimetype.split('/')[1]);

        if (mimetypes && extname) {
            return cb(null, true)
        } else {
            cb('error: images only');
        }
    }
});

module.exports = { upload };