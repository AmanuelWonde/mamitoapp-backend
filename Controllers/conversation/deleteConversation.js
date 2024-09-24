// mysql configurations
const db = require("../../Config/config");
const Joi = require("joi");

// socket configuration
const { io } = require("../../app");

// model imports
const { status, responseInstance } = require("../../Models/response");
const documentation = require("../../documentation/statusCodeDocumentation.json");
const deleteConv = Joi.object({
    conversationId: Joi.number().required(),
    username: Joi.string().min(6).required(),
});

const p1 = (req) => {
    return new Promise((resolve, reject) => {
        const debug = require("debug")("clearconversation:p1");
        const { error } = deleteConv.validate(req.body);
        if (error) {
            debug(error.details[0].message);
            reject(
                new responseInstance(
                    new status(6001, "invalid json content"),
                    error.details[0].message
                )
            );
        } else {
            resolve(req.body);
        }
    });
};

const deleteConversation = (res, body) => {
    const debug = require("debug")("clearconversation:deleteconversation");
    return new Promise((resolve, reject) => {
        db.getConnection((error, connection) => {
            if (error) {
                debug(`Error: ${error}`);
                reject(
                    new responseInstance(
                        new status(7002, documentation[7002]),
                        "this is backend issue"
                    )
                );
            }

            const sql = "CALL DeleteConversation(?, ?)";
            const values = [body.conversationId, body.username];

            connection.query(sql, values, (error, result, fields) => {
                connection.release();

                if (error) {
                    debug(`Error: ${error}`);
                    reject(
                        new responseInstance(
                            new status(7002, documentation[7002]),
                            "this is a backend issue"
                        )
                    );
                    return;
                } else {
                    if (result[0][0].status == 1024) {
                        res.send(
                            new responseInstance(
                                new status(1024, documentation[1024]),
                                "the coversation with the user does not exit"
                            )
                        );
                    } else {
                        resolve(result[1][0]);
                    }
                }
            });
        });
    });
};

const sender = (res, req, result) => {
    res.send(
        new responseInstance(new status(1025), {
            conversationId: result.conversationId,
        })
    );

    let username = req.body.username == result.participant_1 ? result.participant_2: result.participant_1;

    io.emit(username, new responseInstance(new status(1025), {
            conversationId: result.conversationId,
        })
    );
};

module.exports = { p1, deleteConversation, sender };
