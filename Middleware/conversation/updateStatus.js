
module.exports = (req, res) => {
    const { p1, op1, sender } = require('../../Controllers/conversation/conversation');

    p1(req)
        .then((body) => op1(body))
        .then((result) => sender(result, res))
        .catch((error) => console.log(error));
}