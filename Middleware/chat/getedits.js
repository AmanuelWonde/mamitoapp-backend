module.exports = (req, res) => {
    const debugg = require('debug')('getedits:');

    const { schemaValidate, dbOperation, sender } = require('../../Controllers/chat/chat');

    schemaValidate(req, schemaValidate)
        .then((body) => dbOperation(body, 'getedits'))
        .then((result) => sender(result, 'getedits', res))
        .catch((error) => { debugg(error); res.send(error) });
}