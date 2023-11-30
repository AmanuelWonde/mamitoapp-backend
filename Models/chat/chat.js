const Joi = require('joi');

const chatSchema = Joi.object({
    conversationId: Joi.number().integer().min(0).required(),
    sender: Joi.string().min(6).required(),
    message: Joi.string().required(),
});

const chatEditSchema = Joi.object({
    conversationId: Joi.number().integer().required(),
    messageId: Joi.number().integer().required(),
    sender: Joi.string().min(6).required(),
    newMessage: Joi.string().required(),
});

const chatDeleteSchema = Joi.object({
    conversationId: Joi.number().integer().required(),
    messageId: Joi.number().integer().required(),
    sender: Joi.string().min(6).required(),
});

const chatGetSchema = Joi.object({
    username: Joi.string().min(6).required(),
});

const chatGetEdits = Joi.object({
    username: Joi.string().min(6).required(),
});

const chatGet20Schema = Joi.object({
    conversationId: Joi.number().required(),
    earliestMessage: Joi.number().required()
});

module.exports = { chatSchema, chatEditSchema, chatDeleteSchema, chatGetSchema, chatGetEdits, chatGet20Schema };