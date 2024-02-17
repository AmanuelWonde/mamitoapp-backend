module.exports = (req, res) => {

    const { schemaValidate, dbOperation, sender } = require('../../Controllers/chat/chat');

    schemaValidate(req, schemaValidate)
        .then((body) => dbOperation(body, 'insert'))
        .then((result) => sender(result, 'insert', res))
        .catch((error) => { console.log(error); res.send(error) });
}