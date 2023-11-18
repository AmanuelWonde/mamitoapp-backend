module.exports = (req, res) => {
    const debugg = require('debug')('editchat:');

    const { schemaValidate, dbOperation, sender } = require('../../Controllers/chat/chat');

    schemaValidate(req, schemaValidate)
        .then((body) => dbOperation(body, 'edit'))
        .then((result) => sender(result, 'edit', res))
        .catch((error) => { debugg(error); res.send(error) })
}