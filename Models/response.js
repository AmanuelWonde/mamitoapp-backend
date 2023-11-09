class status {
    constructor(code, discription) {
        this.code = code;
        this.discription = discription
    }
}

class responseInstance {
    constructor(status, message) {
        this.status = status;
        this.message = message;
    }
}

module.exports = { status, responseInstance };