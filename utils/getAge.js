const { AgeFromDateString } = require("age-calculator");
const getAge = (birthdate) => {
  const age = new AgeFromDateString(birthdate).age;
  return age;
};
module.exports = getAge;
