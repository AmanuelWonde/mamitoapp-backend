const documentation = require('../documentation/statusCodeDocumentation.json');

class status {
    constructor(code, discription) {
        this.code = code;
        this.discription = documentation[code];
    }
}

class responseInstance {
    constructor(status, message) {
        this.status = status;
        this.content = message;
    }
}

module.exports = { status, responseInstance };