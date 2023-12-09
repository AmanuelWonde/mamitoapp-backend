const findUserMatches = (userAnswers, allUserAnswers) => {
  const yourMatches = [];
  const lengthOfUsers = allUserAnswers.length;
  let userAnswersIndex = 0;

  for (let i = 0; i < lengthOfUsers; i++) {
    const currentMatchingId = allUserAnswers[i].user_username;
    const isMatchedIndex = yourMatches.findIndex(
      (user) => user.user_username === currentMatchingId
    );

    if (isMatchedIndex !== -1) {
      if (
        allUserAnswers[i].choice_id == userAnswers[userAnswersIndex].choice_id
      ) {
        yourMatches[isMatchedIndex].matchPercentage += allUserAnswers[i].value;
        userAnswersIndex++;
      } else {
        userAnswersIndex++;
      }
    } else {
      userAnswersIndex = 0;
      yourMatches.push({
        user_username: currentMatchingId,
        matchPercentage:
          allUserAnswers[i].choice_id == userAnswers[userAnswersIndex].choice_id
            ? allUserAnswers[i].value
            : 0,
      });
    }
  }

  return yourMatches;
};

module.exports = findUserMatches;
