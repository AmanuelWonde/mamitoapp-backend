class status {
    constructor(code, discription) {
        this.code = code;
        this.discription = discription
    }
}

class responseInstance {
    constructor(status, message) {
        this.status = status;
        this.content = message;
    }
}

module.exports = { status, responseInstance };