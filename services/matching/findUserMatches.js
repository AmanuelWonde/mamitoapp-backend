const findUserMatches = (userAnswers, allUserAnswers) => {
  const yourMatches = {};

  for (const userData of allUserAnswers) {
    const currentMatchingId = userData.user_username;
    if (!yourMatches[currentMatchingId]) {
      yourMatches[currentMatchingId] = {
        user_username: currentMatchingId,
        matchPercentage: 0,
        profileImage: userData.profile_image,
      };
    }

    let matchPercentage = 0;

    for (let i = 0; i < userAnswers.length; i++) {
      const foundAnswer = allUserAnswers.find(
        (answer) =>
          answer.user_username === currentMatchingId &&
          answer.questions_id === userAnswers[i].questionId &&
          answer.choice_id === userAnswers[i].choiceId
      );

      if (foundAnswer) {
        matchPercentage += foundAnswer.question_value;
      }
    }

    yourMatches[currentMatchingId].matchPercentage = matchPercentage;
  }

  const sortedMatches = Object.values(yourMatches).sort(
    (a, b) => b.matchPercentage - a.matchPercentage
  );

  return sortedMatches;
};

module.exports = findUserMatches;
