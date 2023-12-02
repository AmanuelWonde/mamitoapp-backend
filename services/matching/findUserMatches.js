const findUserMatches = (userAnswers, allUserAnswers) => {
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

  const lengthOfUsers = allUserAnswers.length;
  let userAnswersIndex = 0;

  // for (let i = 0; i < lengthOfUsers; i++) {
  //   const currentMatchingId = allUserAnswers[i].user_id;
  //   const isMatchedIndex = yourMatches.findIndex(
  //     (user) => user.user_id === currentMatchingId
  //   );

  //   if (isMatchedIndex !== -1) {
  //     if (
  //       allUserAnswers[i].answer_id == userAnswers[userAnswersIndex].answer_id
  //     ) {
  //       yourMatches[isMatchedIndex].matchPercentage += allUserAnswers[i].value;
  //       userAnswersIndex++;
  //     } else {
  //       userAnswersIndex++;
  //     }
  //   } else {
  //     userAnswersIndex = 0;
  //     yourMatches.push({
  //       user_id: currentMatchingId,
  //       matchPercentage:
  //         allUserAnswers[i].answer_id == userAnswers[userAnswersIndex].answer_id
  //           ? allUserAnswers[i].value
  //           : 0,
  //     });
  //   }
  // }

  return yourMatches;
};

module.exports = findUserMatches;
