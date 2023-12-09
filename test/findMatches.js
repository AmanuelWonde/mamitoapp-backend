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
  {
    questionId: 4,
    choiceId: 4,
  },
  {
    questionId: 5,
    choiceId: 5,
  },
];

const otherAnswer = [
  {
    user_id: 1,
    question_id: 1,
    choice_id: 1,
    window_id: 101,
    value: 6,
  },
  {
    user_id: 1,
    question_id: 2,
    choice_id: 2,
    window_id: 101,
    value: 7,
  },
  {
    user_id: 1,
    question_id: 3,
    choice_id: 4,
    window_id: 101,
    value: 4,
  },
  {
    user_id: 1,
    question_id: 4,
    choice_id: 1,
    window_id: 101,
    value: 6.5,
  },
  {
    user_id: 1,
    question_id: 5,
    choice_id: 2,
    window_id: 101,
    value: 7,
  },
  {
    user_id: 2,
    question_id: 1,
    window_id: 101,
    choice_id: 1,
    value: 7,
  },
  {
    user_id: 2,
    question_id: 2,
    window_id: 101,
    choice_id: 2,
    value: 6,
  },
  {
    user_id: 2,
    question_id: 3,
    window_id: 101,
    choice_id: 4,
    value: 5,
  },
  {
    user_id: 2,
    question_id: 4,
    window_id: 101,
    choice_id: 1,
    value: 8,
  },
  {
    user_id: 2,
    question_id: 5,
    window_id: 101,
    choice_id: 2,
    value: 9,
  },
  {
    user_id: 3,
    question_id: 1,
    window_id: 101,
    choice_id: 1,
    value: 5,
  },
  {
    user_id: 3,
    question_id: 2,
    window_id: 101,
    choice_id: 2,
    value: 6.5,
  },
  {
    user_id: 3,
    question_id: 3,
    window_id: 101,
    choice_id: 4,
    value: 7,
  },
  {
    user_id: 3,
    question_id: 4,
    window_id: 101,
    choice_id: 1,
    value: 4,
  },
  {
    user_id: 3,
    question_id: 5,
    window_id: 101,
    choice_id: 2,
    value: 8,
  },
  {
    user_id: 4,
    question_id: 1,
    window_id: 101,
    choice_id: 1,
    value: 6,
  },
  {
    user_id: 4,
    question_id: 2,
    window_id: 101,
    choice_id: 2,
    value: 7.5,
  },
  {
    user_id: 4,
    question_id: 3,
    window_id: 101,
    choice_id: 4,
    value: 6,
  },
  {
    user_id: 4,
    question_id: 4,
    window_id: 101,
    choice_id: 1,
    value: 7,
  },
  {
    user_id: 4,
    question_id: 5,
    window_id: 101,
    choice_id: 2,
    value: 8.5,
  },
  {
    user_id: 5,
    question_id: 1,
    choice_id: 1,
    window_id: 101,
    value: 8,
  },
  {
    user_id: 5,
    choice_id: 2,
    question_id: 2,
    window_id: 101,
    value: 6,
  },
  {
    user_id: 5,
    question_id: 3,
    window_id: 101,
    choice_id: 4,
    value: 7,
  },
  {
    user_id: 5,
    question_id: 4,
    window_id: 101,
    choice_id: 1,
    value: 8,
  },
  {
    user_id: 5,
    question_id: 5,
    choice_id: 2,
    window_id: 101,
    value: 9,
  },
];

const yourMatches = [
  {
    id: 1,
    userName: "amanuelwt",
    profileImage:
      "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=600",
    matchPercentage: 89,
  },
  {
    id: 2,
    userName: "user123",
    profileImage:
      "https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=600",
    matchPercentage: 92,
  },
  {
    id: 3,
    userName: "johndoe",
    profileImage:
      "https://media.istockphoto.com/id/1309328823/photo/headshot-portrait-of-smiling-male-employee-in-office.jpg?b=1&s=612x612&w=0&k=20&c=eU56mZTN4ZXYDJ2SR2DFcQahxEnIl3CiqpP3SOQVbbI=",
    matchPercentage: 78,
  },
  {
    id: 4,
    userName: "coolgirl",
    profileImage:
      "https://images.pexels.com/photos/3763188/pexels-photo-3763188.jpeg?auto=compress&cs=tinysrgb&w=600",
    matchPercentage: 95,
  },
  {
    id: 5,
    userName: "happylife",
    profileImage:
      "https://images.pexels.com/photos/1559486/pexels-photo-1559486.jpeg?auto=compress&cs=tinysrgb&w=600",
    matchPercentage: 86,
  },
  {
    id: 6,
    userName: "codingmaster",
    profileImage:
      "https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?auto=compress&cs=tinysrgb&w=600",
    matchPercentage: 91,
  },
  {
    id: 7,
    userName: "travelbug",
    profileImage:
      "https://images.pexels.com/photos/3785079/pexels-photo-3785079.jpeg?auto=compress&cs=tinysrgb&w=600",
    matchPercentage: 82,
  },
  {
    id: 8,
    userName: "gamingpro",
    profileImage:
      "https://images.pexels.com/photos/762020/pexels-photo-762020.jpeg?auto=compress&cs=tinysrgb&w=600",
    matchPercentage: 88,
  },
  {
    id: 9,
    userName: "musiclover",
    profileImage:
      "https://images.pexels.com/photos/1035673/pexels-photo-1035673.jpeg?auto=compress&cs=tinysrgb&w=600",
    matchPercentage: 90,
  },
  {
    id: 10,
    userName: "bookworm",
    profileImage:
      "https://images.pexels.com/photos/3772510/pexels-photo-3772510.jpeg?auto=compress&cs=tinysrgb&w=600",
    matchPercentage: 84,
  },
];
const yourMatchess = findUserMatches(myAnswers, otherAnswer);
console.log(yourMatchess);
