const fs = require('fs');
const bcrypt = require('bcryptjs');
const emailto = require('../../utils/email');

const { Random, MersenneTwister19937 } = require('random-js');

const engine = MersenneTwister19937.autoSeed();
const random = new Random(engine);

module.exports = async (req, res) => {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const newPassword = random.string(8, characters);

    try {
        // Use 10 salt rounds for bcrypt hashing
        const saltRounds = 10;
        const encPassword = bcrypt.hashSync(newPassword, saltRounds);
        console.log(encPassword);

        // Write the encrypted password to the file
        fs.writeFile('.admin_password', encPassword, 'utf8', (err) => {
            if (err) {
                console.error('Error writing to file:', err);
                return res.status(500).json({ error: "Error while processing request" });
            }
            console.log('written')
        });

        console.log('here')
        // Send an email with the new password
        await emailto('abelrighthere@gmail.com', 'Forgot Password', `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>new generated password</title>
    <style>
        /* Email clients have limited CSS support, so keep it simple */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f9f9f9;
        }
        .container {
            width: 100%;
            padding: 20px;
            background-color: #ffffff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            max-width: 600px;
            margin: 40px auto;
            border-radius: 8px;
            text-align: center;
        }
        .header {
            background-color: #007BFF;
            color: white;
            padding: 10px 0;
            border-radius: 8px 8px 0 0;
        }
        .content {
            padding: 20px;
        }
        .content p {
            font-size: 1.2em;
            margin: 10px 0;
        }
        .otp-code {
            font-size: 2em;
            color: #4CAF50;
            margin: 20px 0;
        }
        .footer {
            margin-top: 30px;
            font-size: 0.9em;
            color: #666666;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Your New Password</h1>
        </div>
        <div class="content">
            <p>Dear User,</p>
            <p>To log in as an admin, please use the following Password :</p>
            <p class="otp-code" id="otp-code">${newPassword}</p>
            <p>It is recommended to change the password after one time use</p>
        </div>
        <div class="footer">
            <p>Thank you for using our service.</p>
            <p>&copy; 2024 Mamito App. All rights reserved.</p>
        </div>
    </div>

    <script>
        var otpCode = '${newPassword}';
        document.getElementById('otp-code').textContent = otpCode;
    </script>
</body>
</html>
`);

        res.status(200).json({ success: true });
    } catch (error) {
        console.error('Error:', error);
        return res.status(500).json({ error: "Error while processing request" });
    }
};
