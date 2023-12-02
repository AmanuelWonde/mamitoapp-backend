const Joi = require('joi');

const newConversation = Joi.object({
    user1: Joi.string().min(6).required(),
    user2: Joi.string().min(6).required()
})

const getConversation = Joi.object({
    username: Joi.string().min(6).required(),
});

const deleteConversation = Joi.object({
    conversationId: Joi.number().integer().positive().required
});

module.exports = { newConversation, getConversation, deleteConversation };