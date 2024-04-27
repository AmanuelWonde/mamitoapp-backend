const getWindowMatchPercentage = (
  matchFinderAnswers,
  toBeMatchedWithAnswers
) => {
  let windowQuestionsMatchPercentage = 0;

  for (let i = 0; i < matchFinderAnswers.length; i++) {
    const foundAnswer = toBeMatchedWithAnswers.find(
      (answer) =>
        answer.questionId === matchFinderAnswers[i].questionId &&
        answer.choiceId === matchFinderAnswers[i].choiceId
    );

    if (foundAnswer) {
      windowQuestionsMatchPercentage += parseFloat(foundAnswer.question_value);
    }
  }
  return windowQuestionsMatchPercentage;
};

module.exports = getWindowMatchPercentage;
