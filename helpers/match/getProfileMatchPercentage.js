const geolib = require("geolib");
const { AgeFromDateString } = require("age-calculator");

const getProfileMatchPercentage = (matchFinder, toBeMatchedWith) => {
  let profileMatchPercentage = 0;

  let matchFinderLocation = {
    latitude: matchFinder.latitude,
    longitude: matchFinder.longitude,
  };

  let toBeMatchedWithLocation = {
    latitude: toBeMatchedWith.latitude,
    longitude: toBeMatchedWith.longitude,
  };

  let distanceBetween = geolib.getDistance(
    matchFinderLocation,
    toBeMatchedWithLocation
  );

  if (distanceBetween <= matchFinder.matchDistance * 1000)
    profileMatchPercentage += 10;

  if (matchFinder.religios === toBeMatchedWith.religios)
    profileMatchPercentage += 5;

  if (matchFinder.verified && toBeMatchedWith.verified)
    profileMatchPercentage += 5;

  if (matchFinder.gender !== toBeMatchedWith.gender) {
    profileMatchPercentage += 5;

    if (
      (matchFinder.gender === "M" &&
        new AgeFromDateString(matchFinder.birthdate).age >
          new AgeFromDateString(toBeMatchedWith.birthdate).age) ||
      (toBeMatchedWith.gender === "M" &&
        new AgeFromDateString(toBeMatchedWith.birthdate).age >
          new AgeFromDateString(matchFinder.birthdate).age)
    ) {
      profileMatchPercentage += 10;
    }
  }

  if (matchFinder.mood === toBeMatchedWith.mood) profileMatchPercentage += 15;

  return {
    profileMatchPercentage,
    distance: distanceBetween,
    age: new AgeFromDateString(toBeMatchedWith.birthdate).age,
  };
};

module.exports = getProfileMatchPercentage;
