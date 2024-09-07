// module imports and configs
const bcrypt = require("bcryptjs");
const JWT = require("jsonwebtoken");

// mysql configurations
const db = require("../../Config/config");

// model imports
const { forgotPassword } = require("../../Models/User");
const { status, responseInstance } = require("../../Models/response");
const documentation = require("../../documentation/statusCodeDocumentation.json");

module.exports = (req, res) => {
  const debug = require("debug")("user:chpd");

  let p1 = new Promise((resolve, reject) => {
    let { error } = forgotPassword.validate(req.body);
    if (error)
      reject(
        new responseInstance(
          new status(6001, documentation[6001]),
          error.details[0].message
        )
      );
    else resolve(req.body);
  });

  //   let checkAnswers = (body) => {
  //     return new Promise((resolve, reject) => {
  //       db.getConnection((error, connection) => {
  //         if (error) {
  //           debug(`Error: ${error}`);
  //           reject(
  //             new responseInstance(
  //               new status(7001, documentation[7001]),
  //               "this is backend issue"
  //             )
  //           );
  //         }

  //         const sql = "CALL ValidateRecoveryAnswers(?,?,?,?,?,?,?)";
  //         const values = [
  //           body.username,
  //           body.id1,
  //           body.id2,
  //           body.id3,
  //           body.ans1,
  //           body.ans2,
  //           body.ans3,
  //         ];

  //         connection.query(sql, values, (error, result) => {
  //           if (error) {
  //             debug(error);
  //           } else {
  //             // console.log(result)
  //             if (result[0][0].status == 1071) {
  //               reject(
  //                 new responseInstance(
  //                   new status(1071),
  //                   "give the correct answer to the questions"
  //                 )
  //               );
  //             } else if (result[0][0].status == 1070) {
  //               resolve(body);
  //             }
  //           }
  //         });
  //       });
  //     });
  //   };

  const passwordEncryption = (body) => {
    return new Promise(async (resolve, reject) => {
      bcrypt.genSalt(10, (err, salt) => {
        if (err) {
          debug(err);
          reject(
            new responseInstance(
              new status(6010, documentation[6010]),
              "this is a backend issue"
            )
          );
        }
        bcrypt.hash(body.newpassword, salt, (err, result) => {
          if (err) {
            debug(err);
            reject(
              new responseInstance(
                new status(6011, documentation[6011]),
                "this is a backend issue"
              )
            );
          }
          resolve(result);
        });
      });
    });
  };

  const store = (encrypted) => {
    return new Promise((resolve, reject) => {
      db.getConnection((error, connection) => {
        if (error) {
          debug(`Error: ${error}`);
          reject(
            new responseInstance(
              new status(7001, documentation[7001]),
              "this is backend issue"
            )
          );
        }

        const sql = "CALL UpdatePassword(?, ?)";
        const values = [req.body.username, encrypted];

        connection.query(sql, values, (error, result) => {
          if (error) {
            debug(error);
            reject(
              new responseInstance(
                new status(7003, documentation[7003]),
                "this is a backend issue"
              )
            );
          } else {
            if (result[0][0].status == 1061) {
              debug(result);
              reject(
                new responseInstance(
                  new status(1061, documentation[1061]),
                  "user not registered"
                )
              );
            } else {
              resolve(result[0][0]);
            }
          }
        });
      });
    });
  };

  const sender = (result) => {
    res.send(
      new responseInstance(
        new status(result.status),
        "password changed successfully"
      )
    );
  };

  p1
    // .then((body) => checkAnswers(body))
    .then((body) => passwordEncryption(body))
    .then((encrypted) => store(encrypted))
    .then((result) => sender(result))
    .catch((error) => res.send(error));
};
