module.exports = (req, res) => {
    const debugg = require('debug')('sendchat:');

    const { schemaValidate, dbOperation, sender } = require('../../Controllers/chat/chat');

    schemaValidate(req, schemaValidate, res)
        .then((body) => dbOperation(body, 'insert'))
        .then((result) => sender(result, 'insert', res))
        .catch((error) => { debugg(error); res.send(error) });
}