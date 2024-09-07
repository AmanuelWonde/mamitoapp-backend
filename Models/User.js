const Joi = require("joi");

const userSchema = Joi.object({
  username: Joi.string().min(6).required(),
  name: Joi.string().required(),
  gender: Joi.string().length(1).required(),
  birthdate: Joi.string()
    .length(10)
    .pattern(/^\d{4}-\d{2}-\d{2}$/)
    .required(),
  password: Joi.string().min(8).required(),
  phone: Joi.string().pattern(/^251[7,9]\d{8}$/),
  bio: Joi.string().allow(null).required(),
  religion: Joi.number().integer().positive().required(),
  changeOneSelf: Joi.number().integer().positive().required(),
  latitude: Joi.number().required(),
  longitude: Joi.number().required(),
});

const loggerSchema = Joi.object({
  username: Joi.alt(
    Joi.string().pattern(/^251[7,9]\d{8}$/),
    Joi.string().min(6).required()
  ),
  password: Joi.string().min(8).required(),
});

const userUpdateSchema = Joi.object({
  username: Joi.string().min(6).required(),
  name: Joi.string(),
  gender: Joi.string().length(1),
  birthdate: Joi.string()
    .length(10)
    .pattern(/^\d{4}-\d{2}-\d{2}$/),
  phone: Joi.string().pattern(/^251[7,9]\d{8}$/),
  bio: Joi.string().allow(null),
  religion: Joi.number().integer().positive(),
  changeOneSelf: Joi.number().integer().positive(),
  latitude: Joi.number(),
  longitude: Joi.number(),
});

const questionFillSchema = Joi.object({
  username: Joi.string().min(6).required(),
  id1: Joi.number().required(),
  id2: Joi.number().required(),
  id3: Joi.number().required(),
  ans1: Joi.string().required(),
  ans2: Joi.string().required(),
  ans3: Joi.string().required(),
});

const changePassword = Joi.object({
  username: Joi.string().required(),
  oldpassword: Joi.string().required(),
  newpassword: Joi.string().required(),
});

const forgotPassword = Joi.object({
  username: Joi.string().required(),
  // id1: Joi.number().required(),
  // id2: Joi.number().required(),
  // id3: Joi.number().required(),
  // ans1: Joi.string().required(),
  // ans2: Joi.string().required(),
  // ans3: Joi.string().required(),
  newpassword: Joi.string().required(),
});

const getRcvQst = Joi.object({
  username: Joi.string().required(),
});
// adf
const updateVerification = Joi.object({
  username: Joi.string().required(),
  verfication: Joi.boolean().required(),
});

module.exports = {
  userSchema,
  loggerSchema,
  userUpdateSchema,
  questionFillSchema,
  changePassword,
  forgotPassword,
  getRcvQst,
  updateVerification,
};
