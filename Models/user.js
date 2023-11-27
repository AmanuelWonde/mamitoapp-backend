const Joi = require('joi');

const userSchema = Joi.object({
    username: Joi.string().min(6).alphanum().required(),
    gender: Joi.string().length(1).required(),
    birthdate: Joi.string().length(10).pattern(/^\d{4}-\d{2}-\d{2}$/).required(),
    phone: Joi.string().pattern(/^251[7,9]\d{8}$/),
    password: Joi.string().min(8).required(),
    bio: Joi.string(),
    religion: Joi.number().integer(),
    changeOneSelf: Joi.number().integer(),
    latitude: Joi.number().required(),
    longitude: Joi.number().required(),
});

const loggerSchema = Joi.object({
    username: Joi.string().min(6).required(),
    password: Joi.string().min(8).required(),
});

module.exports = { userSchema, loggerSchema };