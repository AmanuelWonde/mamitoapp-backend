
module.exports = (req, res) => {
    const { sender, insertConversation, p1 } = require('../../Controllers/conversation/startconversation');

    p1(req)
        .then((body) => insertConversation(body))
        .then((result) => sender(result, res))
        .catch((error) => { console.log(error); res.send(error) });
}