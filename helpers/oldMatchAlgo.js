const findUserMatches = (userAnswers, allUserAnswers) => {
  const yourMatches = {};

  for (const userData of allUserAnswers) {
    const currentMatchingId = userData.username;

    if (!yourMatches[currentMatchingId]) {
      yourMatches[currentMatchingId] = {
        username: currentMatchingId,
        matchPercentage: 0,
        profileImages: userData.profile_images,
        bio: userData.bio,
        name: userData.name,
      };
    }

    let matchPercentage = 0;

    for (let i = 0; i < userAnswers.length; i++) {
      const foundAnswer = allUserAnswers.find(
        (answer) =>
          answer.username === currentMatchingId &&
          answer.questions_id === userAnswers[i].questionId &&
          answer.choice_id === userAnswers[i].choiceId
      );

      if (foundAnswer) {
        matchPercentage += parseFloat(foundAnswer.question_value);
      }
    }

    yourMatches[currentMatchingId].matchPercentage = matchPercentage;
  }

  const sortedMatches = Object.values(yourMatches).sort(
    (a, b) => b.matchPercentage - a.matchPercentage
  );

  return sortedMatches;
};
