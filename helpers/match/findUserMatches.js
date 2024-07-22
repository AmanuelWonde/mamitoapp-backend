const getProfileMatchPercentage = require("./getProfileMatchPercentage");
const getWindowMatchPercentage = require("./getWindowMatchPercentage");

const findUserMatches = (matchFinder, allUserAnswers) => {
  const yourMatches = [];

  for (let i = 0; i < allUserAnswers.length; i++) {
    let { profileMatchPercentage, distance, age, verified, matchDetail } =
      getProfileMatchPercentage(matchFinder, allUserAnswers[i]);

    let windowMatch = getWindowMatchPercentage(
      matchFinder.answers,
      allUserAnswers[i].answers
    );

    matchDetail.Question = windowMatch;
    yourMatches.push({
      username: allUserAnswers[i].username,
      bio: allUserAnswers[i].bio,
      profile_images: allUserAnswers[i].profile_images,
      matchPercentage: (profileMatchPercentage + windowMatch) / 2,
      distance: distance,
      age,
      verified,
      matchDetail,
    });
  }

  return yourMatches;
};

module.exports = findUserMatches;
