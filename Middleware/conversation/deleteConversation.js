
module.exports = (req, res) => {
    const { sender, deleteConversation, p1 } = require('../../Controllers/conversation/deleteConversation.js');

    p1(req)
        .then((body) => deleteConversation(body))
        .then((code) => sender(res, code))
        .catch(error => { res.send(error) });
}