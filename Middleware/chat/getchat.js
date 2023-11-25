module.exports = (req, res) => {
    const debugg = require('debug')('sendchat:');

    const { schemaValidate, dbOperation, sender } = require('../../Controllers/chat/chat');

    schemaValidate(req, schemaValidate)
        .then((body) => dbOperation(body, 'getChat'))
        .then((result) => sender(result, 'getChat', res))
        .catch((error) => { debugg(error); res.send(error) });
}