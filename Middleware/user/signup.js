// module imports and configs
const bcrypt = require("bcryptjs");
const JWT = require("jsonwebtoken");

// mysql configurations
const db = require("../../Config/config");

// model imports
const { userSchema } = require("../../Models/User");
const { status, responseInstance } = require("../../Models/response");
const documentation = require("../../documentation/statusCodeDocumentation.json");

module.exports = (req, res) => {
  const debugg = require("debug")("signup:reject");

  let p1 = new Promise((resolve, reject) => {
    let { error } = userSchema.validate(req.body);
    if (error)
      reject(
        new responseInstance(
          new status(6001, documentation[6001]),
          error.details[0].message
        )
      );
    else resolve(req.body);
  });

  function passwordEncryption(body) {
    const debug = require("debug")("signup:encrypting");
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
        bcrypt.hash(body.password, salt, (err, result) => {
          if (err) {
            debug(err);
            reject(
              new responseInstance(
                new status(6011, documentation[6011]),
                "this is a backend issue"
              )
            );
          }

          body.password = result;
          resolve(body);
        });
      });
    });
  }

  function insertData(body) {
    const debug = require("debug")("signup:inserting");
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

        const sql = "CALL InsertUser(?,?,?,?,?,?,?,?,?,?,?)";
        const values = [
          body.username,
          body.name,
          body.gender,
          body.birthdate,
          body.phone,
          body.password,
          body.bio || null,
          body.religion || null,
          body.changeOneSelf || null,
          body.latitude || null,
          body.longitude || null,
        ];

        connection.query(sql, values, (error, result, fields) => {
          if (error) {
            console.log(error);
            reject(
              new responseInstance(new status(7002, documentation[7002]), error)
            );
          } else {
            console.log(result);
            if (result[0][0].status == 1011) {
              reject(
                new responseInstance(
                  new status(1011, documentation[1011]),
                  "try another username"
                )
              );
            } else if (result[0][0].status == 1012) {
              reject(
                new responseInstance(
                  new status(1012, documentation[1012]),
                  "to create new account use another phone"
                )
              );
            } else {
              resolve(result[0][0]);
            }
          }
        });
      });
    });
  }

  function sender(result) {
    const auth_token = JWT.sign(
      {
        username: result.username,
        name: result.name,
        gender: result.gender,
        birthdate: result.birthdate,
        phone: result.phone,
        bio: result.bio,
        religion: result.religion,
        changeOneSelf: result.changeOneSelf,
        longitude: result.longitude,
        latitude: result.latitude,
        verified: 0
      },
      "hiruy"
    );
    res
      .setHeader("auth-token", auth_token)
      .send(
        new responseInstance(
          new status(1010, documentation[1010]),
          result.username
        )
      );
  }

  const deviceId = (body) => {
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

        const sql = "CALL InsertDeviceId(?, ?)";
        const values = [body.username, req.header("deviceId")];

        connection.query(sql, values, (error, result) => {
          connection.release();

          if (error) {
            console.log(error);
          } else {
            resolve(body);
          }
        });
      });
    });
  };

  p1.then((body) => passwordEncryption(body))
    .then((body) => insertData(body))
    .then((body) => deviceId(body))
    .then((result) => sender(result))
    .catch((error) => {
      res.send(error);
      debugg(error);
    });
};
