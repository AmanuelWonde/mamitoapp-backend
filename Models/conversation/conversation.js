const Joi = require('joi');

const newConversation = Joi.object({
    user1: Joi.string().min(6).required(),
    user2: Joi.string().min(6).required(),
    match: Joi.number().required()
})

const getConversation = Joi.object({
    username: Joi.string().min(6).required(),
});

const deleteConversation = Joi.object({
    conversationId: Joi.number().integer().positive().required
});

const updateConversation = Joi.object({
    id: Joi.number().required(),
    op: Joi.string().required()
})

module.exports = { newConversation, getConversation, deleteConversation, updateConversation };