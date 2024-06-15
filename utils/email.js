const nodemailer = require('nodemailer');

const sendEmail = (
  sendTo,
  subject,
  html,
) => {
  const transporter = nodemailer.createTransport({
    host: "mamitoapp.com",
    port: 465,
    secure: true,
    auth: {
      user: "admin@mamitoapp.com",
      pass: "YdSV5O!&D4@t",
    },
  });

  return transporter.sendMail({
    from: "admin@mamitoapp.com",
    to: sendTo,
    subject: subject,
    html: html,
  });
};

module.exports = sendEmail;
