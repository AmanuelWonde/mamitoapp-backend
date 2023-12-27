
module.exports = (req, res) => {
    const { sender, insertConversation, p1 } = require('../../Controllers/conversation/conversation');

    p1(req)
        .then((body) => insertConversation(body))
        .then((result) => sender(result, res))
        .catch((error) => { debugg(error); res.send(error) });
}