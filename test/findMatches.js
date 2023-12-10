const findUserMatches = require("../services/matching/findUserMatches");

const myAnswers = [
  {
    questionId: 1,
    choiceId: 1,
  },
  {
    questionId: 2,
    choiceId: 2,
  },
  {
    questionId: 3,
    choiceId: 3,
  },
];

const otherAnswers = [
  {
    id: 1,
    user_username: "user123",
    questions_id: 1,
    choice_id: 1,
    window_id: 101,
    profile_image: "path/to/profile/image1.jpg",
    question_value: 42, // Numeric question value
  },
  {
    id: 2,
    window_id: 101,
    user_username: "user123",
    questions_id: 2,
    choice_id: 2,
    profile_image: "path/to/profile/image2.jpg",
    question_value: 7, // Numeric question value
  },
  {
    id: 2,
    window_id: 101,
    user_username: "user123",
    questions_id: 3,
    choice_id: 3,
    profile_image: "path/to/profile/image2.jpg",
    question_value: 7, // Numeric question value
  },
  {
    id: 3,
    window_id: 103,
    choice_id: 3,
    questions_id: 1,
    user_username: "user789",
    profile_image: "path/to/profile/image3.jpg",
    question_value: 99,
  },
  {
    id: 3,
    window_id: 103,
    choice_id: 2,
    questions_id: 2,
    user_username: "user789",
    profile_image: "path/to/profile/image3.jpg",
    question_value: 99,
  },
  {
    id: 3,
    window_id: 103,
    choice_id: 3,
    questions_id: 3,
    user_username: "user789",
    profile_image: "path/to/profile/image3.jpg",
    question_value: 99,
  },
  {
    id: 3,
    window_id: 103,
    choice_id: 3,
    questions_id: 1,
    user_username: "user889",
    profile_image: "path/to/profile/image3.jpg",
    question_value: 99,
  },
  {
    id: 3,
    window_id: 103,
    choice_id: 3,
    questions_id: 2,
    user_username: "user889",
    profile_image: "path/to/profile/image3.jpg",
    question_value: 99,
  },
  {
    id: 3,
    window_id: 103,
    choice_id: 3,
    questions_id: 3,
    user_username: "user889",
    profile_image: "path/to/profile/image3.jpg",
    question_value: 99,
  },
];

const yourMatches = findUserMatches(myAnswers, otherAnswers);
console.log(yourMatches);
