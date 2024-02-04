module.exports = (req, res) => {

    const { validateSchema, update, sender } = require('../../Controllers/user/updateVerified');

    validateSchema(req)
        .then((body) => update(body))
        .then((result) => sender(req, res, result))
        .catch((error) => res.send(error));
}