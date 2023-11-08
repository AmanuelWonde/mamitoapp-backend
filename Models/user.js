const Joi = require('joi');

const userSchema = Joi.object({
    username: Joi.string().min(6).alphanum().required(),
    gender: Joi.string().length(1).required(),
    phone: Joi.string().pattern(/^251[7,9]\d{8}$/),
    age: Joi.number().integer().min(13).required(),
    email: Joi.string().email().required(),
    educationalStatus: Joi.string(),
    employmentStatus: Joi.string(),
    bio: Joi.string(),
    religion: Joi.string(),
    currentLocation: Joi.object({
        latitude: Joi.number(),
        longitude: Joi.number()
    }),
    password: Joi.string().min(8).required(),
});

module.exports = { userSchema };