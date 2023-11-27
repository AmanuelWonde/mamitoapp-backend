const findUserMatches = (userAnswers, allUserAnswers) => {
  const yourMatches = [];
  const lengthOfUsers = allUserAnswers.length;
  let userAnswersIndex = 0;

  for (let i = 0; i < lengthOfUsers; i++) {
    const currentMatchingId = allUserAnswers[i].user_id;
    const isMatchedIndex = yourMatches.findIndex(
      (user) => user.user_id === currentMatchingId
    );

    if (isMatchedIndex !== -1) {
      if (
        allUserAnswers[i].answer_id == userAnswers[userAnswersIndex].answer_id
      ) {
        yourMatches[isMatchedIndex].matchPercentage += allUserAnswers[i].value;
        userAnswersIndex++;
      } else {
        userAnswersIndex++;
      }
    } else {
      userAnswersIndex = 0;
      yourMatches.push({
        user_id: currentMatchingId,
        matchPercentage:
          allUserAnswers[i].answer_id == userAnswers[userAnswersIndex].answer_id
            ? allUserAnswers[i].value
            : 0,
      });
    }
  }
  return yourMatches;
};

module.exports = findUserMatches;
