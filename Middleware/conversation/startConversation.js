module.exports = (req, res) => {
    const { sender, insertConversation, p1 } = require('../../Controllers/conversation/startconversation');
    const { fcm } = require('../../app');
    const getFCMtoken = require('../../Controllers/getFCMtoken');

    let message;
    p1(req)
        .then((body) => insertConversation(body))
        .then((result) => {sender(result, res); message = result})
        // .then(() => {
        //     message = {
        //         notification: {
        //             title: "new message",
        //             body: message['user-2']
        //         },
        //         data: {
        //             sender: message['user-1']
        //         },
        //         to: getFCMtoken(message['user-2'])
        //     }

        //     fcm.send(message, function (err, response) {
        //         if (err) console.log(err)
        //         else console.log(response);
        //     })
        // })
        .catch((error) => { res.send(error) });
}