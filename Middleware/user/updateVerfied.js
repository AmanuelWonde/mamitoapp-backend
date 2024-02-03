module.exports = (req, res) => {

    const { validateSchema, update, sender } = require('../../Controllers/user/updateVerified');

    validateSchema(req)
        .then((body) => update(body))
        .then(() => sender(req, res))
        .catch((error) => res.send(error));
}