const Joi = require('joi');

const newConversation = Joi.object({
    user1: Joi.string().min(6).required(),
    user2: Joi.string().min(6).required()
})

const getConversation = Joi.object({
    username: Joi.string().min(6).required(),
})

module.exports = { newConversation, getConversation };