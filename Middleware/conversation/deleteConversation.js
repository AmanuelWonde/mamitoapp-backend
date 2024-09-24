
module.exports = (req, res) => {
    const { sender, deleteConversation, p1 } = require('../../Controllers/conversation/deleteConversation.js');

    p1(req)
        .then((body) => deleteConversation(res, body))
        .then((code) => sender(res, req, code))
        .catch(error => { console.log('set - header', error) /* res.send(error) */ });
}
