const Joi = require('joi');

const userSchema = Joi.object({
    username: Joi.string().min(6).alphanum().required(),
    gender: Joi.string().length(1).required(),
    phone: Joi.string().pattern(/^251[7,9]\d{8}$/),
    birthdate: Joi.string().length(10).pattern(/^\d{4}-\d{2}-\d{2}$/).required(),
    email: Joi.string().email().required(),
    educationalStatus: Joi.string(),
    employmentStatus: Joi.string(),
    bio: Joi.string(),
    religion: Joi.string(),
    currentLocation: Joi.object({
        latitude: Joi.number().required(),
        longitude: Joi.number().required()
    }),
    password: Joi.string().min(8).required(),
});

const loggerSchema = Joi.object({
    username_phone: Joi.alt(Joi.string().pattern(/^251[7,9]\d{8}$/), Joi.string().min(6).required()),
    password: Joi.string().min(8).required(),
});

module.exports = { userSchema, loggerSchema };