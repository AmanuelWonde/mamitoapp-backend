const nodemailer = require("nodemailer");
const sendEmail = async (
    sendTo,
    subject,
    text,
    html,
) => {
    const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
            user: "triptransports@gmail.com",
            pass: "bvrc qvpj lpqt weas",
        },
    });

    try {
        const info = await transporter.sendMail({
            from: "mamito",
            to: sendTo,
            subject: subject,
            text: text,
            html: html,
        });

        console.log(info);
        return info;
    } catch (error) {
        console.log(error);
        return error;
    }
};

module.exports = sendEmail;
