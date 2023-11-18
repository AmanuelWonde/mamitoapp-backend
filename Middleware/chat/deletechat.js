module.exports = (req, res) => {
    const debugg = require('debug')('deletechat:');

    const { schemaValidate, dbOperation, sender } = require('../../Controllers/chat/chat');

    schemaValidate(req, schemaValidate)
        .then((body) => dbOperation(body, 'delete'))
        .then((result) => sender(result, 'delete', res))
        .catch((error) => { debugg(error); res.send(error) })
}