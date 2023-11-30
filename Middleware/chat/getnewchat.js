module.exports = (req, res) => {
    const debugg = require('debug')('getnewchat:');

    const { schemaValidate, dbOperation, sender } = require('../../Controllers/chat/chat');

    schemaValidate(req, schemaValidate)
        .then((body) => dbOperation(body, 'get'))
        .then((result) => sender(result, 'get', res))
        .catch((error) => { debugg(error); res.send(error) });
}