module.exports = (req, res) => {
    const debugg = require('debug')('chat:mar');

    const { schemaValidate, dbOperation, sender } = require('../../Controllers/chat/chat');

    schemaValidate(req, schemaValidate)
        .then((body) => dbOperation(body, 'mar'))
        .then((result) => sender(result, 'mar', res))
        .catch((error) => { debugg(error); res.send(error) })
}