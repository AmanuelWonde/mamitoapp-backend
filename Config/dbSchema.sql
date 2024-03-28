-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 19, 2024 at 06:11 AM
-- Server version: 8.0.36-cll-lve
-- PHP Version: 8.1.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mamitogw_mamito`
--

DELIMITER $$
--
-- Procedures
--
CREATE PROCEDURE `AddProfileImage` (IN `image` VARCHAR(300), IN `userName` VARCHAR(45), OUT `imageId` INT)   BEGIN
INSERT INTO `profile-images` (image, user_username)
VALUES(image, userName);
 SET imageId = LAST_INSERT_ID();
END$$

CREATE PROCEDURE `AddProfileQuestionsAnswer` (IN `userName` INT(45), IN `questionId` INT, IN `choiceId` INT)   BEGIN
INSERT INTO `profile-question-answers`(user_username, `profile-questions_id`, `profile-question-choices_id`)
VALUES(userName, questionId, choiceId);
END$$

CREATE PROCEDURE `AddVerificationImage` (IN `image` VARCHAR(200), IN `sampleImageId` INT, IN `username` VARCHAR(50))   BEGIN
INSERT INTO `user-verification-images`(image, `sample-verification-images_id`, user_username)
VALUES(image, sampleImageId, username);
END$$

CREATE PROCEDURE `CheckIfUserAnswersWindow` (IN `username` VARCHAR(200), IN `windowId` INT)   BEGIN
    DECLARE user_answer_count INT;

    SELECT COUNT(*) INTO user_answer_count
    FROM answers
    WHERE user_username = username AND window_id = windowId;

    IF user_answer_count > 0 THEN
        SELECT 1 AS UserAnsweredWindow;
    ELSE
        SELECT 0 AS UserAnsweredWindow;
    END IF;
END$$

$$

$$

CREATE PROCEDURE `CurrentWindowQuestions` (IN `windowId` INT)   BEGIN
    SELECT q.question AS question, q.id AS id, q.question_value AS `value`,
        JSON_ARRAYAGG(JSON_OBJECT('id', c.id, 'choice', c.choice, 'image', c.image)) AS choices
    FROM questions q
    LEFT JOIN choices c ON q.id = c.questions_id
    WHERE q.windows_id = windowId
    GROUP BY q.id;
END$$

$$

$$

CREATE PROCEDURE `DeleteProfileImage` (IN `userName` VARCHAR(45), IN `imageId` INT)   BEGIN
    DECLARE image_url VARCHAR(300);

    SELECT image INTO image_url
    FROM `profile-images`
    WHERE user_username = userName AND id = imageId;

    IF image_url IS NOT NULL THEN
        INSERT INTO `deleted-profile-images` (user_username, image)
        VALUES (userName, image_url);

        DELETE FROM `profile-images`
        WHERE user_username = userName AND id = imageId;
        END IF;
END$$

CREATE PROCEDURE `deleteWindow` (IN `windowId` INT)   BEGIN
DELETE FROM windows
WHERE id = windowId;
END$$

$$

CREATE PROCEDURE `FindMatches` (IN `windowId` INT)   BEGIN
SELECT answers.*, `user`.`urlProfileImage`, questions.question_value
FROM answers
JOIN `user` ON `user`.username = answers.user_username
JOIN questions ON questions.id = answers.questions_id
WHERE answers.window_id = windowId;
END$$

$$

$$

CREATE PROCEDURE `GetCurrentOrNextWindow` ()   BEGIN
    DECLARE p_current_window_id INT;
    DECLARE p_next_window_start_at DATETIME;

    SELECT id INTO p_current_window_id
    FROM `windows`
    WHERE CURRENT_TIMESTAMP BETWEEN `start_at` AND `end_at`
    ORDER BY `start_at`
    LIMIT 1;

    IF p_current_window_id IS NULL THEN
        SELECT `start_at` INTO p_next_window_start_at
        FROM `windows`
        WHERE `start_at` > CURRENT_TIMESTAMP
        ORDER BY `start_at`
        LIMIT 1;

        SELECT DATE_FORMAT(p_next_window_start_at,
        '%Y-%m-%d %H:%i:%s')  AS NextWindowStartTime;

    ELSE
        SELECT `start_at` INTO p_next_window_start_at
        FROM `windows`
        WHERE `start_at` > (SELECT `end_at` FROM `windows`           WHERE id = p_current_window_id)
        ORDER BY `start_at`
        LIMIT 1;

       SELECT p_current_window_id AS CurrentWindowID,              DATE_FORMAT(p_next_window_start_at, 
      '%Y-%m-%d %H:%i:%s') AS NextWindowStartTime;
    END IF;
END$$

$$

$$

$$

$$

$$

$$

$$

CREATE PROCEDURE `GetSampleImages` (IN `inputGender` VARCHAR(50))   BEGIN
    SELECT * FROM `sample-verification-images` 
    WHERE gender = inputGender;
END$$

$$

$$

CREATE PROCEDURE `GetWindow` ()   BEGIN
SELECT 
id, name, `status`,
    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') AS created_at,
    DATE_FORMAT(start_at, '%Y-%m-%d %H:%i:%s') AS start_at,
    DATE_FORMAT(end_at, '%Y-%m-%d %H:%i:%s') AS end_at 
   FROM windows;
END$$

CREATE PROCEDURE `GetWindowId` ()   BEGIN
    SELECT *
    FROM windows
    WHERE CURRENT_TIMESTAMP BETWEEN 
    start_at AND
    end_at;
END$$

CREATE PROCEDURE `GetWindowQuestions` (IN `windowId` INT)   BEGIN
SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
        'question', q.question,
        'value', q.question_value,
        'id', q.id,
        'choices', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'choice', c.choice,
                    'image', c.image
                )
            )
            FROM choices c WHERE q.id =   c.questions_id
        )
    )
) FROM questions q  WHERE windows_id =   windowId;
END$$

$$

CREATE PROCEDURE `InsertChoice` (IN `questionId` INT, IN `choiceValue` VARCHAR(100), IN `image` VARCHAR(255))  DETERMINISTIC BEGIN
    INSERT INTO choices (questions_id, choice, image)
    VALUES (questionId, choiceValue, image);
END$$

$$

$$

$$

$$

CREATE PROCEDURE `InsertProfileQuestion` (IN `question` TEXT, IN `questionValue` DECIMAL(2), OUT `id` INT)   BEGIN 
INSERT INTO `profile-questions`(question, question_value)
VALUES(question, questionValue);
SET id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE `InsertProfileQuestionChoices` (IN `questionId` INT, IN `choice` VARCHAR(100))   BEGIN 
INSERT INTO `profile-question-choices` (choice, `profile-questions_id`)
VALUES (choice, questionId);
END$$

CREATE PROCEDURE `InsertQuestion` (IN `question` VARCHAR(100), IN `windowId` INT, IN `questionValue` DECIMAL, OUT `insertedId` INT)   BEGIN
    INSERT INTO questions (question, question_value, windows_id)
    VALUES (question, questionValue, windowId);
    SET insertedId = LAST_INSERT_ID();
END$$

CREATE PROCEDURE `InsertSampleImage` (IN `image` VARCHAR(200), IN `gender` VARCHAR(45))   BEGIN
INSERT INTO `sample-verification-images`(image, gender)
VALUES (image, gender);
END$$

$$

CREATE PROCEDURE `InsertUserAnswers` (IN `windowId` INT, IN `userName` VARCHAR(255), IN `questionId` INT, IN `choiceId` INT)   BEGIN
    INSERT INTO answers (window_id, user_username, questions_id, choice_id)
    VALUES (windowId, userName, questionId, choiceId);
END$$

CREATE PROCEDURE `InsertWindow` (IN `name` VARCHAR(50), IN `startDate` DATETIME, IN `endDate` DATETIME, OUT `insertedId` INT)   BEGIN
    INSERT INTO windows (name, start_at, end_at)
    VALUES (name, startDate, endDate);
      SET insertedId = LAST_INSERT_ID();
END$$

$$

$$

$$

$$

$$

CREATE PROCEDURE `UpdateProfileQuestionsAnswer` (IN `userName` VARCHAR(45), IN `questionId` INT, IN `choiceId` INT)   BEGIN
UPDATE `profile-question-answers` 
SET `profile-question-choices_id` = choiceId
WHERE `profile-questions_id` = questionId AND user_username = userName;
END$$

$$

$$

CREATE PROCEDURE `UpdateWindow` (IN `windowId` INT, IN `newName` VARCHAR(200), IN `newStartAt` DATETIME, IN `newEndAt` DATETIME)   BEGIN
UPDATE windows
    SET
        name = newName,
        start_at = newStartAt,
        end_at = newEndAt
    WHERE
        id = windowId;
END$$

$$

CREATE PROCEDURE `ValidateUserImages` (IN `validateStatus` VARCHAR(50), IN `username` VARCHAR(50), IN `sampleImageId` INT)   BEGIN
    UPDATE `user-verification-images`
    SET `status` = validateStatus
    WHERE `user-verification-images`.`user_username` = username 
    AND `user-verification-images`.`sample-verification-images_id` = sampleImageId;
END$$

CREATE PROCEDURE `ViewProfileImages` (IN `userName` VARCHAR(45))   BEGIN
SELECT id, image FROM `profile-images` 
WHERE user_username = userName;
END$$

CREATE PROCEDURE `ViewUserVerificationImages` ()   BEGIN
SELECT uvi.`sample-verification-images_id`  AS sampleImageId, uvi.image, uvi.status, uvi.user_username AS username, svi.image AS sampleImage
FROM `user-verification-images` uvi
INNER JOIN `sample-verification-images` svi ON uvi.`sample-verification-images_id` = svi.id
WHERE uvi.status = 'pending';
END$$

--
-- Functions
--
CREATE FUNCTION `F_GetConversationStartDate` (`p_conversation_id` INT) RETURNS DATETIME DETERMINISTIC READS SQL DATA BEGIN
	DECLARE time DATETIME;
    
    SELECT `created-at` INTO time
    FROM `mamitogw_mamito`.`conversation`
    WHERE `conversation-id` = p_conversation_id;
    
    RETURN time;
END$$

$$

CREATE FUNCTION `F_LastMessage` (`p_conversation_id` INT) RETURNS VARCHAR(999) CHARSET utf8mb3 DETERMINISTIC READS SQL DATA BEGIN
    DECLARE v_message VARCHAR(999);
    
    -- Get the latest message for the specified conversation
    SELECT `message` INTO v_message
    FROM `mamitogw_mamito`.`message`
    WHERE `conversation-id` = p_conversation_id
    ORDER BY `id-messages` DESC
    LIMIT 1;
    
    RETURN v_message;
END$$

CREATE FUNCTION `F_Unread_Messages` (`p_conversation_id` INT, `p_username` VARCHAR(45)) RETURNS INT DETERMINISTIC READS SQL DATA BEGIN
    DECLARE v_markasread INT;
    DECLARE v_user VARCHAR(45);

    -- Get the latest message ID for the conversation
    SELECT MAX(`id-messages`) INTO v_markasread
    FROM `mamitogw_mamito`.`message`
    WHERE `conversation-id` = p_conversation_id;

    -- Get the sender of the latest message
    SELECT `sender` INTO v_user
    FROM `mamitogw_mamito`.`message`
    WHERE `conversation-id` = p_conversation_id AND `id-messages` = v_markasread;

    -- Check if the latest message was sent by the other participant
    IF p_username = v_user THEN
        RETURN v_markasread;
    ELSE 
        RETURN 1;
    END IF;
END$$

CREATE FUNCTION `F_User_Bio` (`p_username` VARCHAR(45)) RETURNS VARCHAR(200) CHARSET utf8mb3 DETERMINISTIC READS SQL DATA BEGIN
	DECLARE v_bio VARCHAR(200);
    
    SELECT `bio` INTO v_bio
    FROM `mamitogw_mamito`.`user`
    WHERE `username` = p_username;
    
    RETURN v_bio;
END$$

CREATE FUNCTION `F_User_Birthdate` (`p_username` VARCHAR(45)) RETURNS DATETIME DETERMINISTIC READS SQL DATA BEGIN
	DECLARE v_bd DATETIME;
    
    SELECT `birthdate` INTO v_bd
    FROM `mamitogw_mamito`.`user`
    WHERE `username` = p_username;
    
    RETURN v_bd;
END$$

CREATE FUNCTION `F_User_ChangeOneSelf` (`p_username` VARCHAR(45)) RETURNS INT DETERMINISTIC READS SQL DATA BEGIN
	DECLARE v_cos INT;
    
    SELECT `changeoneself` INTO v_cos
    FROM `mamitogw_mamito`.`user`
    WHERE `username` = p_username;
    
    RETURN v_cos;
END$$

CREATE FUNCTION `F_User_Gender` (`p_username` VARCHAR(45)) RETURNS ENUM('M','F') CHARSET utf8mb3 DETERMINISTIC READS SQL DATA BEGIN
	DECLARE v_gender ENUM("M", "F");
    
    SELECT `gender` INTO v_gender
    FROM `mamitogw_mamito`.`user`
    WHERE `username` = p_username;
    
    RETURN v_gender;
END$$

CREATE FUNCTION `F_User_Name` (`p_username` VARCHAR(45)) RETURNS VARCHAR(45) CHARSET utf8mb3 DETERMINISTIC READS SQL DATA BEGIN
	DECLARE v_name VARCHAR(45);
    
    SELECT `name` INTO v_name
    FROM `mamitogw_mamito`.`user`
    WHERE `username` = p_username;
    
    RETURN v_name;
END$$

CREATE FUNCTION `F_User_Phone` (`p_username` VARCHAR(45)) RETURNS BIGINT DETERMINISTIC READS SQL DATA BEGIN
	DECLARE v_phone BIGINT;
    
    SELECT `phone` INTO v_phone
    FROM `mamitogw_mamito`.`user`
    WHERE `username` = p_username;
    
    RETURN v_phone;
END$$

CREATE FUNCTION `F_User_Religion` (`p_username` VARCHAR(45)) RETURNS INT DETERMINISTIC READS SQL DATA BEGIN
	DECLARE v_r INT;
    
    SELECT `religion` INTO v_r
    FROM `mamitogw_mamito`.`user`
    WHERE `username` = p_username;
    
    RETURN v_r;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id` int NOT NULL,
  `creataed-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `answers`
--

CREATE TABLE `answers` (
  `id` int NOT NULL,
  `window_id` int NOT NULL,
  `choice_id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `questions_id` int NOT NULL,
  `user_username` varchar(45) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `answers`
--

INSERT INTO `answers` (`id`, `window_id`, `choice_id`, `created_at`, `updated_at`, `questions_id`, `user_username`) VALUES
(274, 60, 1, '2024-02-11 10:07:17', '2024-02-11 10:07:17', 107, 'amanw'),
(273, 60, 1, '2024-02-11 10:07:17', '2024-02-11 10:07:17', 106, 'amanw'),
(272, 60, 1, '2024-02-11 10:02:20', '2024-02-11 10:02:20', 108, 'amanw'),
(271, 60, 1, '2024-02-11 10:02:20', '2024-02-11 10:02:20', 107, 'amanw'),
(270, 60, 1, '2024-02-11 10:02:20', '2024-02-11 10:02:20', 106, 'amanw'),
(269, 60, 1, '2024-02-11 09:58:28', '2024-02-11 09:58:28', 108, 'amanw'),
(268, 60, 1, '2024-02-11 09:58:28', '2024-02-11 09:58:28', 107, 'amanw'),
(267, 60, 1, '2024-02-11 09:58:28', '2024-02-11 09:58:28', 106, 'amanw'),
(266, 60, 1, '2024-02-11 09:56:31', '2024-02-11 09:56:31', 108, 'amanw'),
(265, 60, 1, '2024-02-11 09:56:31', '2024-02-11 09:56:31', 107, 'amanw'),
(264, 60, 1, '2024-02-11 09:56:31', '2024-02-11 09:56:31', 106, 'amanw'),
(263, 60, 1, '2024-02-09 20:26:22', '2024-02-09 20:26:22', 108, 'amanw'),
(262, 60, 1, '2024-02-09 20:26:22', '2024-02-09 20:26:22', 107, 'amanw'),
(261, 60, 1, '2024-02-09 20:26:22', '2024-02-09 20:26:22', 106, 'amanw'),
(260, 60, 1, '2024-02-09 19:57:04', '2024-02-09 19:57:04', 108, 'amanw'),
(259, 60, 1, '2024-02-09 19:57:04', '2024-02-09 19:57:04', 107, 'amanw'),
(258, 60, 1, '2024-02-09 19:57:04', '2024-02-09 19:57:04', 106, 'amanw'),
(257, 60, 1, '2024-02-09 19:48:40', '2024-02-09 19:48:40', 108, 'amanw'),
(256, 60, 1, '2024-02-09 19:48:40', '2024-02-09 19:48:40', 107, 'amanw'),
(255, 60, 1, '2024-02-09 19:48:40', '2024-02-09 19:48:40', 106, 'amanw'),
(254, 60, 1, '2024-02-09 19:08:23', '2024-02-09 19:08:23', 108, 'amanw'),
(253, 60, 1, '2024-02-09 19:08:23', '2024-02-09 19:08:23', 107, 'amanw'),
(252, 60, 1, '2024-02-09 19:08:23', '2024-02-09 19:08:23', 106, 'amanw'),
(251, 60, 1, '2024-02-09 18:45:43', '2024-02-09 18:45:43', 108, 'amanw'),
(250, 60, 1, '2024-02-09 18:45:43', '2024-02-09 18:45:43', 107, 'amanw'),
(249, 60, 1, '2024-02-09 18:45:43', '2024-02-09 18:45:43', 106, 'amanw'),
(248, 60, 1, '2024-02-09 18:41:30', '2024-02-09 18:41:30', 108, 'amanw'),
(247, 60, 1, '2024-02-09 18:41:30', '2024-02-09 18:41:30', 107, 'amanw'),
(246, 60, 1, '2024-02-09 18:41:30', '2024-02-09 18:41:30', 106, 'amanw'),
(245, 60, 1, '2024-02-09 18:36:57', '2024-02-09 18:36:57', 108, 'amanw'),
(244, 60, 1, '2024-02-09 18:36:57', '2024-02-09 18:36:57', 107, 'amanw'),
(243, 60, 1, '2024-02-09 18:36:57', '2024-02-09 18:36:57', 106, 'amanw'),
(242, 60, 1, '2024-02-09 18:32:57', '2024-02-09 18:32:57', 108, 'amanw'),
(241, 60, 1, '2024-02-09 18:32:57', '2024-02-09 18:32:57', 107, 'amanw'),
(240, 60, 1, '2024-02-09 18:32:57', '2024-02-09 18:32:57', 106, 'amanw'),
(239, 60, 1, '2024-02-09 18:25:50', '2024-02-09 18:25:50', 108, 'amanw'),
(238, 60, 1, '2024-02-09 18:25:50', '2024-02-09 18:25:50', 107, 'amanw'),
(237, 60, 1, '2024-02-09 18:25:50', '2024-02-09 18:25:50', 106, 'amanw'),
(236, 60, 1, '2024-02-09 18:23:49', '2024-02-09 18:23:49', 108, 'amanw'),
(235, 60, 1, '2024-02-09 18:23:49', '2024-02-09 18:23:49', 107, 'amanw'),
(234, 60, 1, '2024-02-09 18:23:49', '2024-02-09 18:23:49', 106, 'amanw'),
(233, 60, 1, '2024-02-09 18:21:55', '2024-02-09 18:21:55', 108, 'amanw'),
(232, 60, 1, '2024-02-09 18:21:55', '2024-02-09 18:21:55', 107, 'amanw'),
(231, 60, 1, '2024-02-09 18:21:55', '2024-02-09 18:21:55', 106, 'amanw'),
(230, 60, 1, '2024-02-09 18:19:31', '2024-02-09 18:19:31', 108, 'amanw'),
(229, 60, 1, '2024-02-09 18:19:31', '2024-02-09 18:19:31', 107, 'amanw'),
(228, 60, 1, '2024-02-09 18:19:31', '2024-02-09 18:19:31', 106, 'amanw'),
(227, 60, 1, '2024-02-09 18:15:58', '2024-02-09 18:15:58', 108, 'amanw'),
(226, 60, 1, '2024-02-09 18:15:58', '2024-02-09 18:15:58', 107, 'amanw'),
(225, 60, 1, '2024-02-09 18:15:58', '2024-02-09 18:15:58', 106, 'amanw'),
(224, 60, 1, '2024-02-09 18:11:38', '2024-02-09 18:11:38', 108, 'amanw'),
(223, 60, 1, '2024-02-09 18:11:38', '2024-02-09 18:11:38', 107, 'amanw'),
(222, 60, 1, '2024-02-09 18:11:38', '2024-02-09 18:11:38', 106, 'amanw'),
(221, 60, 1, '2024-02-09 18:06:05', '2024-02-09 18:06:05', 108, 'amanw'),
(220, 60, 1, '2024-02-09 18:06:05', '2024-02-09 18:06:05', 107, 'amanw'),
(219, 60, 1, '2024-02-09 18:06:05', '2024-02-09 18:06:05', 106, 'amanw'),
(218, 60, 1, '2024-02-09 18:03:12', '2024-02-09 18:03:12', 108, 'amanw'),
(217, 60, 1, '2024-02-09 18:03:12', '2024-02-09 18:03:12', 107, 'amanw'),
(216, 60, 1, '2024-02-09 18:03:12', '2024-02-09 18:03:12', 106, 'amanw'),
(215, 60, 1, '2024-02-09 17:56:06', '2024-02-09 17:56:06', 108, 'amanw'),
(214, 60, 1, '2024-02-09 17:56:06', '2024-02-09 17:56:06', 107, 'amanw'),
(213, 60, 1, '2024-02-09 17:56:06', '2024-02-09 17:56:06', 106, 'amanw'),
(212, 60, 1, '2024-02-09 17:48:38', '2024-02-09 17:48:38', 108, 'amanw'),
(211, 60, 1, '2024-02-09 17:48:38', '2024-02-09 17:48:38', 107, 'amanw'),
(210, 60, 1, '2024-02-09 17:48:38', '2024-02-09 17:48:38', 106, 'amanw'),
(209, 60, 1, '2024-02-07 16:01:37', '2024-02-07 16:01:37', 108, 'amanw'),
(208, 60, 1, '2024-02-07 16:01:37', '2024-02-07 16:01:37', 107, 'amanw'),
(207, 60, 1, '2024-02-07 16:01:37', '2024-02-07 16:01:37', 106, 'amanw'),
(206, 60, 1, '2024-02-07 14:40:56', '2024-02-07 14:40:56', 108, 'amanw'),
(205, 60, 1, '2024-02-07 14:40:56', '2024-02-07 14:40:56', 107, 'amanw'),
(204, 60, 1, '2024-02-07 14:40:56', '2024-02-07 14:40:56', 106, 'amanw'),
(203, 60, 183, '2024-02-06 18:13:24', '2024-02-06 18:13:24', 108, 'amanw'),
(202, 60, 182, '2024-02-06 18:13:24', '2024-02-06 18:13:24', 107, 'amanw'),
(201, 60, 177, '2024-02-06 18:13:24', '2024-02-06 18:13:24', 106, 'amanw'),
(200, 60, 184, '2024-02-06 18:10:35', '2024-02-06 18:10:35', 108, 'amanw'),
(199, 60, 181, '2024-02-06 18:10:35', '2024-02-06 18:10:35', 107, 'amanw'),
(198, 60, 178, '2024-02-06 18:10:35', '2024-02-06 18:10:35', 106, 'amanw'),
(197, 60, 1, '2024-02-06 15:07:25', '2024-02-06 15:07:25', 108, 'amanw'),
(196, 60, 1, '2024-02-06 15:07:25', '2024-02-06 15:07:25', 107, 'amanw'),
(195, 60, 1, '2024-02-06 15:07:25', '2024-02-06 15:07:25', 106, 'amanw'),
(194, 60, 1, '2024-02-06 14:51:30', '2024-02-06 14:51:30', 108, 'amanw'),
(193, 60, 1, '2024-02-06 14:51:30', '2024-02-06 14:51:30', 107, 'amanw'),
(192, 60, 1, '2024-02-06 14:51:29', '2024-02-06 14:51:29', 106, 'amanw'),
(191, 60, 1, '2024-02-06 07:05:25', '2024-02-06 07:05:25', 108, 'amanw'),
(190, 60, 1, '2024-02-06 07:05:25', '2024-02-06 07:05:25', 107, 'amanw'),
(189, 60, 1, '2024-02-06 07:05:25', '2024-02-06 07:05:25', 106, 'amanw'),
(188, 60, 183, '2024-02-06 07:05:25', '2024-02-06 07:05:25', 108, 'amanw'),
(187, 60, 181, '2024-02-06 07:05:25', '2024-02-06 07:05:25', 107, 'amanw'),
(186, 60, 177, '2024-02-06 07:05:25', '2024-02-06 07:05:25', 106, 'amanw'),
(185, 60, 1, '2024-02-06 05:47:10', '2024-02-06 05:47:10', 108, 'amanw'),
(184, 60, 1, '2024-02-06 05:47:10', '2024-02-06 05:47:10', 107, 'amanw'),
(183, 60, 1, '2024-02-06 05:47:10', '2024-02-06 05:47:10', 106, 'amanw'),
(182, 60, 183, '2024-02-06 05:46:21', '2024-02-06 05:46:21', 108, 'amanw'),
(181, 60, 181, '2024-02-06 05:46:21', '2024-02-06 05:46:21', 107, 'amanw'),
(180, 60, 177, '2024-02-06 05:46:21', '2024-02-06 05:46:21', 106, 'amanw'),
(179, 60, 1, '2024-02-04 16:59:35', '2024-02-04 16:59:35', 108, 'amanw'),
(178, 60, 1, '2024-02-04 16:59:35', '2024-02-04 16:59:35', 107, 'amanw'),
(177, 60, 1, '2024-02-04 16:59:35', '2024-02-04 16:59:35', 106, 'amanw'),
(176, 60, 1, '2024-02-04 13:48:28', '2024-02-04 13:48:28', 108, 'amanw'),
(175, 60, 1, '2024-02-04 13:48:28', '2024-02-04 13:48:28', 107, 'amanw'),
(174, 60, 1, '2024-02-04 13:48:28', '2024-02-04 13:48:28', 106, 'amanw'),
(275, 60, 1, '2024-02-11 10:07:17', '2024-02-11 10:07:17', 108, 'amanw'),
(276, 60, 1, '2024-02-11 10:27:57', '2024-02-11 10:27:57', 106, 'amanw'),
(277, 60, 1, '2024-02-11 10:27:57', '2024-02-11 10:27:57', 107, 'amanw'),
(278, 60, 1, '2024-02-11 10:27:57', '2024-02-11 10:27:57', 108, 'amanw'),
(279, 60, 1, '2024-02-11 10:48:12', '2024-02-11 10:48:12', 106, 'amanw'),
(280, 60, 1, '2024-02-11 10:48:12', '2024-02-11 10:48:12', 107, 'amanw'),
(281, 60, 1, '2024-02-11 10:48:12', '2024-02-11 10:48:12', 108, 'amanw'),
(282, 60, 1, '2024-02-11 11:13:48', '2024-02-11 11:13:48', 106, 'amanw'),
(283, 60, 1, '2024-02-11 11:13:48', '2024-02-11 11:13:48', 107, 'amanw'),
(284, 60, 1, '2024-02-11 11:13:48', '2024-02-11 11:13:48', 108, 'amanw'),
(285, 60, 1, '2024-02-11 11:32:31', '2024-02-11 11:32:31', 106, 'amanw'),
(286, 60, 1, '2024-02-11 11:32:31', '2024-02-11 11:32:31', 107, 'amanw'),
(287, 60, 1, '2024-02-11 11:32:31', '2024-02-11 11:32:31', 108, 'amanw'),
(288, 60, 1, '2024-02-11 11:48:27', '2024-02-11 11:48:27', 106, 'amanw'),
(289, 60, 1, '2024-02-11 11:48:27', '2024-02-11 11:48:27', 107, 'amanw'),
(290, 60, 1, '2024-02-11 11:48:27', '2024-02-11 11:48:27', 108, 'amanw'),
(291, 60, 1, '2024-02-11 12:53:57', '2024-02-11 12:53:57', 106, 'amanw'),
(292, 60, 1, '2024-02-11 12:53:57', '2024-02-11 12:53:57', 107, 'amanw'),
(293, 60, 1, '2024-02-11 12:53:57', '2024-02-11 12:53:57', 108, 'amanw'),
(294, 60, 1, '2024-02-11 15:42:43', '2024-02-11 15:42:43', 106, 'amanw'),
(295, 60, 1, '2024-02-11 15:42:43', '2024-02-11 15:42:43', 107, 'amanw'),
(296, 60, 1, '2024-02-11 15:42:43', '2024-02-11 15:42:43', 108, 'amanw'),
(297, 60, 1, '2024-02-11 15:56:47', '2024-02-11 15:56:47', 106, 'amanw'),
(298, 60, 1, '2024-02-11 15:56:47', '2024-02-11 15:56:47', 107, 'amanw'),
(299, 60, 1, '2024-02-11 15:56:47', '2024-02-11 15:56:47', 108, 'amanw'),
(300, 60, 1, '2024-02-11 15:59:32', '2024-02-11 15:59:32', 106, 'amanw'),
(301, 60, 1, '2024-02-11 15:59:32', '2024-02-11 15:59:32', 107, 'amanw'),
(302, 60, 1, '2024-02-11 15:59:32', '2024-02-11 15:59:32', 108, 'amanw'),
(303, 60, 1, '2024-02-11 16:05:30', '2024-02-11 16:05:30', 106, 'amanw'),
(304, 60, 1, '2024-02-11 16:05:30', '2024-02-11 16:05:30', 107, 'amanw'),
(305, 60, 1, '2024-02-11 16:05:30', '2024-02-11 16:05:30', 108, 'amanw'),
(306, 60, 1, '2024-02-11 17:31:23', '2024-02-11 17:31:23', 106, 'amanw'),
(307, 60, 1, '2024-02-11 17:31:23', '2024-02-11 17:31:23', 107, 'amanw'),
(308, 60, 1, '2024-02-11 17:31:23', '2024-02-11 17:31:23', 108, 'amanw'),
(309, 60, 1, '2024-02-11 19:38:20', '2024-02-11 19:38:20', 106, 'amanw'),
(310, 60, 1, '2024-02-11 19:38:20', '2024-02-11 19:38:20', 107, 'amanw'),
(311, 60, 1, '2024-02-11 19:38:20', '2024-02-11 19:38:20', 108, 'amanw'),
(312, 60, 1, '2024-02-11 19:40:23', '2024-02-11 19:40:23', 106, 'amanw'),
(313, 60, 1, '2024-02-11 19:40:23', '2024-02-11 19:40:23', 107, 'amanw'),
(314, 60, 1, '2024-02-11 19:40:23', '2024-02-11 19:40:23', 108, 'amanw'),
(315, 60, 1, '2024-02-11 19:50:50', '2024-02-11 19:50:50', 106, 'amanw'),
(316, 60, 1, '2024-02-11 19:50:50', '2024-02-11 19:50:50', 107, 'amanw'),
(317, 60, 1, '2024-02-11 19:50:50', '2024-02-11 19:50:50', 108, 'amanw'),
(318, 60, 1, '2024-02-13 10:54:08', '2024-02-13 10:54:08', 106, 'amanw'),
(319, 60, 1, '2024-02-13 10:54:08', '2024-02-13 10:54:08', 107, 'amanw'),
(320, 60, 1, '2024-02-13 10:54:08', '2024-02-13 10:54:08', 108, 'amanw'),
(321, 60, 1, '2024-02-13 11:00:14', '2024-02-13 11:00:14', 106, 'amanw'),
(322, 60, 1, '2024-02-13 11:00:14', '2024-02-13 11:00:14', 107, 'amanw'),
(323, 60, 1, '2024-02-13 11:00:14', '2024-02-13 11:00:14', 108, 'amanw'),
(324, 60, 1, '2024-02-13 11:03:15', '2024-02-13 11:03:15', 106, 'amanw'),
(325, 60, 1, '2024-02-13 11:03:15', '2024-02-13 11:03:15', 107, 'amanw'),
(326, 60, 1, '2024-02-13 11:03:15', '2024-02-13 11:03:15', 108, 'amanw'),
(327, 60, 1, '2024-02-13 11:07:40', '2024-02-13 11:07:40', 106, 'amanw'),
(328, 60, 1, '2024-02-13 11:07:40', '2024-02-13 11:07:40', 107, 'amanw'),
(329, 60, 1, '2024-02-13 11:07:40', '2024-02-13 11:07:40', 108, 'amanw'),
(330, 60, 1, '2024-02-13 11:11:37', '2024-02-13 11:11:37', 106, 'amanw'),
(331, 60, 1, '2024-02-13 11:11:37', '2024-02-13 11:11:37', 107, 'amanw'),
(332, 60, 1, '2024-02-13 11:11:37', '2024-02-13 11:11:37', 108, 'amanw'),
(333, 60, 1, '2024-02-13 18:35:29', '2024-02-13 18:35:29', 106, 'amanw'),
(334, 60, 1, '2024-02-13 18:35:29', '2024-02-13 18:35:29', 107, 'amanw'),
(335, 60, 1, '2024-02-13 18:35:29', '2024-02-13 18:35:29', 108, 'amanw'),
(336, 60, 1, '2024-02-13 18:35:30', '2024-02-13 18:35:30', 106, 'amanw'),
(337, 60, 1, '2024-02-13 18:35:30', '2024-02-13 18:35:30', 107, 'amanw'),
(338, 60, 1, '2024-02-13 18:35:30', '2024-02-13 18:35:30', 108, 'amanw'),
(339, 60, 1, '2024-02-13 19:57:30', '2024-02-13 19:57:30', 106, 'amanw'),
(340, 60, 1, '2024-02-13 19:57:30', '2024-02-13 19:57:30', 107, 'amanw'),
(341, 60, 1, '2024-02-13 19:57:30', '2024-02-13 19:57:30', 108, 'amanw'),
(342, 60, 1, '2024-02-13 20:21:54', '2024-02-13 20:21:54', 106, 'amanw'),
(343, 60, 1, '2024-02-13 20:21:54', '2024-02-13 20:21:54', 107, 'amanw'),
(344, 60, 1, '2024-02-13 20:21:54', '2024-02-13 20:21:54', 108, 'amanw'),
(345, 60, 1, '2024-02-13 20:30:00', '2024-02-13 20:30:00', 106, 'amanw'),
(346, 60, 1, '2024-02-13 20:30:00', '2024-02-13 20:30:00', 107, 'amanw'),
(347, 60, 1, '2024-02-13 20:30:00', '2024-02-13 20:30:00', 108, 'amanw'),
(348, 60, 179, '2024-02-15 10:22:24', '2024-02-15 10:22:24', 106, 'amanw'),
(349, 60, 182, '2024-02-15 10:22:24', '2024-02-15 10:22:24', 107, 'amanw'),
(350, 60, 183, '2024-02-15 10:22:24', '2024-02-15 10:22:24', 108, 'amanw'),
(351, 60, 177, '2024-02-15 10:22:59', '2024-02-15 10:22:59', 106, 'amanw'),
(352, 60, 182, '2024-02-15 10:22:59', '2024-02-15 10:22:59', 107, 'amanw'),
(353, 60, 183, '2024-02-15 10:22:59', '2024-02-15 10:22:59', 108, 'amanw'),
(354, 60, 179, '2024-02-15 10:23:37', '2024-02-15 10:23:37', 106, 'amanw'),
(355, 60, 182, '2024-02-15 10:23:37', '2024-02-15 10:23:37', 107, 'amanw'),
(356, 60, 183, '2024-02-15 10:23:37', '2024-02-15 10:23:37', 108, 'amanw'),
(357, 60, 178, '2024-02-15 10:23:37', '2024-02-15 10:23:37', 106, 'amanw'),
(358, 60, 181, '2024-02-15 10:23:37', '2024-02-15 10:23:37', 107, 'amanw'),
(359, 60, 184, '2024-02-15 10:23:37', '2024-02-15 10:23:37', 108, 'amanw'),
(360, 60, 1, '2024-02-15 10:25:54', '2024-02-15 10:25:54', 106, 'amanw'),
(361, 60, 1, '2024-02-15 10:25:54', '2024-02-15 10:25:54', 107, 'amanw'),
(362, 60, 1, '2024-02-15 10:25:54', '2024-02-15 10:25:54', 108, 'amanw'),
(363, 60, 1, '2024-02-15 10:28:12', '2024-02-15 10:28:12', 106, 'amanw'),
(364, 60, 1, '2024-02-15 10:28:12', '2024-02-15 10:28:12', 107, 'amanw'),
(365, 60, 1, '2024-02-15 10:28:12', '2024-02-15 10:28:12', 108, 'amanw'),
(366, 60, 178, '2024-02-15 10:30:44', '2024-02-15 10:30:44', 106, 'amanw'),
(367, 60, 181, '2024-02-15 10:30:44', '2024-02-15 10:30:44', 107, 'amanw'),
(368, 60, 184, '2024-02-15 10:30:44', '2024-02-15 10:30:44', 108, 'amanw'),
(369, 60, 178, '2024-02-15 10:31:00', '2024-02-15 10:31:00', 106, 'amanw'),
(370, 60, 181, '2024-02-15 10:31:00', '2024-02-15 10:31:00', 107, 'amanw'),
(371, 60, 184, '2024-02-15 10:31:00', '2024-02-15 10:31:00', 108, 'amanw'),
(372, 60, 1, '2024-02-15 10:32:21', '2024-02-15 10:32:21', 106, 'amanw'),
(373, 60, 1, '2024-02-15 10:32:21', '2024-02-15 10:32:21', 107, 'amanw'),
(374, 60, 1, '2024-02-15 10:32:21', '2024-02-15 10:32:21', 108, 'amanw'),
(375, 60, 1, '2024-02-15 10:34:08', '2024-02-15 10:34:08', 106, 'amanw'),
(376, 60, 1, '2024-02-15 10:34:08', '2024-02-15 10:34:08', 107, 'amanw'),
(377, 60, 1, '2024-02-15 10:34:08', '2024-02-15 10:34:08', 108, 'amanw'),
(378, 60, 1, '2024-02-15 10:39:17', '2024-02-15 10:39:17', 106, 'amanw'),
(379, 60, 1, '2024-02-15 10:39:17', '2024-02-15 10:39:17', 107, 'amanw'),
(380, 60, 1, '2024-02-15 10:39:17', '2024-02-15 10:39:17', 108, 'amanw'),
(381, 60, 178, '2024-02-15 10:39:17', '2024-02-15 10:39:17', 106, 'amanw'),
(382, 60, 181, '2024-02-15 10:39:17', '2024-02-15 10:39:17', 107, 'amanw'),
(383, 60, 184, '2024-02-15 10:39:17', '2024-02-15 10:39:17', 108, 'amanw'),
(384, 60, 1, '2024-02-15 10:39:17', '2024-02-15 10:39:17', 106, 'amanw'),
(385, 60, 1, '2024-02-15 10:39:17', '2024-02-15 10:39:17', 107, 'amanw'),
(386, 60, 1, '2024-02-15 10:39:17', '2024-02-15 10:39:17', 108, 'amanw'),
(387, 60, 1, '2024-02-15 10:41:26', '2024-02-15 10:41:26', 106, 'amanw'),
(388, 60, 1, '2024-02-15 10:41:26', '2024-02-15 10:41:26', 107, 'amanw'),
(389, 60, 1, '2024-02-15 10:41:26', '2024-02-15 10:41:26', 108, 'amanw'),
(390, 60, 1, '2024-02-15 10:41:26', '2024-02-15 10:41:26', 106, 'amanw'),
(391, 60, 182, '2024-02-15 10:41:26', '2024-02-15 10:41:26', 107, 'amanw'),
(392, 60, 183, '2024-02-15 10:41:26', '2024-02-15 10:41:26', 108, 'amanw'),
(393, 60, 1, '2024-02-15 10:41:54', '2024-02-15 10:41:54', 106, 'amanw'),
(394, 60, 1, '2024-02-15 10:41:54', '2024-02-15 10:41:54', 107, 'amanw'),
(395, 60, 1, '2024-02-15 10:41:54', '2024-02-15 10:41:54', 108, 'amanw'),
(396, 60, 178, '2024-02-15 10:41:54', '2024-02-15 10:41:54', 106, 'amanw'),
(397, 60, 181, '2024-02-15 10:41:54', '2024-02-15 10:41:54', 107, 'amanw'),
(398, 60, 184, '2024-02-15 10:41:54', '2024-02-15 10:41:54', 108, 'amanw'),
(399, 60, 1, '2024-02-15 10:41:54', '2024-02-15 10:41:54', 106, 'amanw'),
(400, 60, 1, '2024-02-15 10:41:54', '2024-02-15 10:41:54', 107, 'amanw'),
(401, 60, 1, '2024-02-15 10:41:54', '2024-02-15 10:41:54', 108, 'amanw'),
(402, 60, 178, '2024-02-15 10:43:21', '2024-02-15 10:43:21', 106, 'amanw'),
(403, 60, 181, '2024-02-15 10:43:21', '2024-02-15 10:43:21', 107, 'amanw'),
(404, 60, 184, '2024-02-15 10:43:21', '2024-02-15 10:43:21', 108, 'amanw'),
(405, 60, 178, '2024-02-15 10:45:57', '2024-02-15 10:45:57', 106, 'amanw'),
(406, 60, 181, '2024-02-15 10:45:57', '2024-02-15 10:45:57', 107, 'amanw'),
(407, 60, 184, '2024-02-15 10:45:57', '2024-02-15 10:45:57', 108, 'amanw'),
(408, 60, 1, '2024-02-15 10:45:57', '2024-02-15 10:45:57', 106, 'amanw'),
(409, 60, 1, '2024-02-15 10:45:57', '2024-02-15 10:45:57', 107, 'amanw'),
(410, 60, 1, '2024-02-15 10:45:57', '2024-02-15 10:45:57', 108, 'amanw'),
(411, 60, 1, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 106, 'amanw'),
(412, 60, 1, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 107, 'amanw'),
(413, 60, 1, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 108, 'amanw'),
(414, 60, 178, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 106, 'amanw'),
(415, 60, 181, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 107, 'amanw'),
(416, 60, 184, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 108, 'amanw'),
(417, 60, 1, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 106, 'amanw'),
(418, 60, 1, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 107, 'amanw'),
(419, 60, 1, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 108, 'amanw'),
(420, 60, 178, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 106, 'amanw'),
(421, 60, 181, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 107, 'amanw'),
(422, 60, 184, '2024-02-15 10:46:22', '2024-02-15 10:46:22', 108, 'amanw'),
(423, 60, 178, '2024-02-15 10:51:39', '2024-02-15 10:51:39', 106, 'amanw'),
(424, 60, 181, '2024-02-15 10:51:39', '2024-02-15 10:51:39', 107, 'amanw'),
(425, 60, 184, '2024-02-15 10:51:39', '2024-02-15 10:51:39', 108, 'amanw'),
(426, 60, 178, '2024-02-15 10:52:57', '2024-02-15 10:52:57', 106, 'amanw'),
(427, 60, 181, '2024-02-15 10:52:57', '2024-02-15 10:52:57', 107, 'amanw'),
(428, 60, 184, '2024-02-15 10:52:57', '2024-02-15 10:52:57', 108, 'amanw'),
(429, 60, 1, '2024-02-15 10:54:38', '2024-02-15 10:54:38', 106, 'amanw'),
(430, 60, 1, '2024-02-15 10:54:38', '2024-02-15 10:54:38', 107, 'amanw'),
(431, 60, 1, '2024-02-15 10:54:38', '2024-02-15 10:54:38', 108, 'amanw'),
(432, 60, 178, '2024-02-15 10:56:13', '2024-02-15 10:56:13', 106, 'amanw'),
(433, 60, 181, '2024-02-15 10:56:13', '2024-02-15 10:56:13', 107, 'amanw'),
(434, 60, 184, '2024-02-15 10:56:13', '2024-02-15 10:56:13', 108, 'amanw'),
(435, 60, 178, '2024-02-15 10:56:29', '2024-02-15 10:56:29', 106, 'abelSeyoum'),
(436, 60, 181, '2024-02-15 10:56:29', '2024-02-15 10:56:29', 107, 'abelSeyoum'),
(437, 60, 184, '2024-02-15 10:56:29', '2024-02-15 10:56:29', 108, 'abelSeyoum'),
(438, 60, 178, '2024-02-15 11:05:19', '2024-02-15 11:05:19', 106, 'beamlak123'),
(439, 60, 181, '2024-02-15 11:05:19', '2024-02-15 11:05:19', 107, 'beamlak123'),
(440, 60, 184, '2024-02-15 11:05:19', '2024-02-15 11:05:19', 108, 'beamlak123'),
(441, 60, 1, '2024-02-15 11:08:21', '2024-02-15 11:08:21', 106, 'abelSeyoum'),
(442, 60, 182, '2024-02-15 11:08:21', '2024-02-15 11:08:21', 107, 'abelSeyoum'),
(443, 60, 183, '2024-02-15 11:08:21', '2024-02-15 11:08:21', 108, 'abelSeyoum'),
(444, 60, 178, '2024-02-15 11:09:38', '2024-02-15 11:09:38', 106, 'amanw'),
(445, 60, 181, '2024-02-15 11:09:38', '2024-02-15 11:09:38', 107, 'amanw'),
(446, 60, 184, '2024-02-15 11:09:38', '2024-02-15 11:09:38', 108, 'amanw'),
(447, 60, 178, '2024-02-15 11:11:11', '2024-02-15 11:11:11', 106, 'amanw'),
(448, 60, 181, '2024-02-15 11:11:11', '2024-02-15 11:11:11', 107, 'amanw'),
(449, 60, 184, '2024-02-15 11:11:11', '2024-02-15 11:11:11', 108, 'amanw'),
(450, 60, 1, '2024-02-15 11:11:47', '2024-02-15 11:11:47', 106, 'abelSeyoum'),
(451, 60, 1, '2024-02-15 11:11:47', '2024-02-15 11:11:47', 107, 'abelSeyoum'),
(452, 60, 1, '2024-02-15 11:11:47', '2024-02-15 11:11:47', 108, 'abelSeyoum'),
(453, 60, 1, '2024-02-15 11:13:47', '2024-02-15 11:13:47', 106, 'amanw'),
(454, 60, 1, '2024-02-15 11:13:47', '2024-02-15 11:13:47', 107, 'amanw'),
(455, 60, 1, '2024-02-15 11:13:47', '2024-02-15 11:13:47', 108, 'amanw'),
(456, 60, 1, '2024-02-15 11:21:36', '2024-02-15 11:21:36', 106, 'amanw'),
(457, 60, 1, '2024-02-15 11:21:36', '2024-02-15 11:21:36', 107, 'amanw'),
(458, 60, 1, '2024-02-15 11:21:36', '2024-02-15 11:21:36', 108, 'amanw'),
(459, 60, 1, '2024-02-15 11:26:02', '2024-02-15 11:26:02', 106, 'amanw'),
(460, 60, 1, '2024-02-15 11:26:02', '2024-02-15 11:26:02', 107, 'amanw'),
(461, 60, 1, '2024-02-15 11:26:03', '2024-02-15 11:26:03', 108, 'amanw'),
(462, 60, 178, '2024-02-15 11:30:25', '2024-02-15 11:30:25', 106, 'amanw'),
(463, 60, 181, '2024-02-15 11:30:25', '2024-02-15 11:30:25', 107, 'amanw'),
(464, 60, 184, '2024-02-15 11:30:25', '2024-02-15 11:30:25', 108, 'amanw'),
(465, 60, 178, '2024-02-15 11:32:02', '2024-02-15 11:32:02', 106, 'amanw'),
(466, 60, 181, '2024-02-15 11:32:02', '2024-02-15 11:32:02', 107, 'amanw'),
(467, 60, 184, '2024-02-15 11:32:02', '2024-02-15 11:32:02', 108, 'amanw'),
(468, 60, 178, '2024-02-15 11:35:20', '2024-02-15 11:35:20', 106, 'amanw'),
(469, 60, 181, '2024-02-15 11:35:20', '2024-02-15 11:35:20', 107, 'amanw'),
(470, 60, 184, '2024-02-15 11:35:20', '2024-02-15 11:35:20', 108, 'amanw'),
(471, 60, 1, '2024-02-15 11:37:56', '2024-02-15 11:37:56', 106, 'amanw'),
(472, 60, 1, '2024-02-15 11:37:56', '2024-02-15 11:37:56', 107, 'amanw'),
(473, 60, 1, '2024-02-15 11:37:56', '2024-02-15 11:37:56', 108, 'amanw'),
(474, 60, 178, '2024-02-15 11:40:00', '2024-02-15 11:40:00', 106, 'amanw'),
(475, 60, 181, '2024-02-15 11:40:00', '2024-02-15 11:40:00', 107, 'amanw'),
(476, 60, 184, '2024-02-15 11:40:00', '2024-02-15 11:40:00', 108, 'amanw'),
(477, 60, 178, '2024-02-15 11:41:52', '2024-02-15 11:41:52', 106, 'amanw'),
(478, 60, 181, '2024-02-15 11:41:52', '2024-02-15 11:41:52', 107, 'amanw'),
(479, 60, 184, '2024-02-15 11:41:52', '2024-02-15 11:41:52', 108, 'amanw'),
(480, 60, 178, '2024-02-15 11:42:43', '2024-02-15 11:42:43', 106, 'amanw'),
(481, 60, 181, '2024-02-15 11:42:43', '2024-02-15 11:42:43', 107, 'amanw'),
(482, 60, 184, '2024-02-15 11:42:43', '2024-02-15 11:42:43', 108, 'amanw'),
(483, 60, 1, '2024-02-15 11:44:59', '2024-02-15 11:44:59', 106, 'amanw'),
(484, 60, 182, '2024-02-15 11:44:59', '2024-02-15 11:44:59', 107, 'amanw'),
(485, 60, 183, '2024-02-15 11:44:59', '2024-02-15 11:44:59', 108, 'amanw'),
(486, 60, 178, '2024-02-15 11:46:30', '2024-02-15 11:46:30', 106, 'amanw'),
(487, 60, 181, '2024-02-15 11:46:30', '2024-02-15 11:46:30', 107, 'amanw'),
(488, 60, 184, '2024-02-15 11:46:30', '2024-02-15 11:46:30', 108, 'amanw'),
(489, 60, 1, '2024-02-15 11:48:08', '2024-02-15 11:48:08', 106, 'amanw'),
(490, 60, 182, '2024-02-15 11:48:08', '2024-02-15 11:48:08', 107, 'amanw'),
(491, 60, 183, '2024-02-15 11:48:08', '2024-02-15 11:48:08', 108, 'amanw'),
(492, 60, 1, '2024-02-15 11:57:17', '2024-02-15 11:57:17', 106, 'amanw'),
(493, 60, 1, '2024-02-15 11:57:17', '2024-02-15 11:57:17', 107, 'amanw'),
(494, 60, 1, '2024-02-15 11:57:17', '2024-02-15 11:57:17', 108, 'amanw'),
(495, 60, 1, '2024-02-15 12:10:56', '2024-02-15 12:10:56', 106, 'abelSeyoum'),
(496, 60, 1, '2024-02-15 12:10:56', '2024-02-15 12:10:56', 107, 'abelSeyoum'),
(497, 60, 1, '2024-02-15 12:10:56', '2024-02-15 12:10:56', 108, 'abelSeyoum'),
(498, 60, 1, '2024-02-15 12:17:09', '2024-02-15 12:17:09', 106, 'amanw'),
(499, 60, 1, '2024-02-15 12:17:09', '2024-02-15 12:17:09', 107, 'amanw'),
(500, 60, 1, '2024-02-15 12:17:09', '2024-02-15 12:17:09', 108, 'amanw'),
(501, 60, 1, '2024-02-16 09:07:56', '2024-02-16 09:07:56', 106, 'amanw'),
(502, 60, 1, '2024-02-16 09:07:57', '2024-02-16 09:07:57', 107, 'amanw'),
(503, 60, 1, '2024-02-16 09:07:57', '2024-02-16 09:07:57', 108, 'amanw'),
(504, 60, 179, '2024-02-17 12:42:25', '2024-02-17 12:42:25', 106, 'beamlak123'),
(505, 60, 182, '2024-02-17 12:42:25', '2024-02-17 12:42:25', 107, 'beamlak123'),
(506, 60, 183, '2024-02-17 12:42:25', '2024-02-17 12:42:25', 108, 'beamlak123'),
(507, 60, 178, '2024-02-17 14:36:38', '2024-02-17 14:36:38', 106, 'beamlak321'),
(508, 60, 181, '2024-02-17 14:36:38', '2024-02-17 14:36:38', 107, 'beamlak321'),
(509, 60, 184, '2024-02-17 14:36:38', '2024-02-17 14:36:38', 108, 'beamlak321'),
(510, 60, 1, '2024-02-17 14:37:07', '2024-02-17 14:37:07', 106, 'beamlak321'),
(511, 60, 1, '2024-02-17 14:37:07', '2024-02-17 14:37:07', 107, 'beamlak321'),
(512, 60, 1, '2024-02-17 14:37:07', '2024-02-17 14:37:07', 108, 'beamlak321'),
(513, 60, 1, '2024-02-17 14:39:14', '2024-02-17 14:39:14', 106, 'beamlak321'),
(514, 60, 1, '2024-02-17 14:39:14', '2024-02-17 14:39:14', 107, 'beamlak321'),
(515, 60, 1, '2024-02-17 14:39:14', '2024-02-17 14:39:14', 108, 'beamlak321'),
(516, 60, 1, '2024-02-17 14:59:29', '2024-02-17 14:59:29', 106, 'beamlak321'),
(517, 60, 1, '2024-02-17 14:59:29', '2024-02-17 14:59:29', 107, 'beamlak321'),
(518, 60, 1, '2024-02-17 14:59:29', '2024-02-17 14:59:29', 108, 'beamlak321'),
(519, 60, 1, '2024-02-17 18:23:09', '2024-02-17 18:23:09', 106, 'beamlak123'),
(520, 60, 1, '2024-02-17 18:23:09', '2024-02-17 18:23:09', 107, 'beamlak123'),
(521, 60, 1, '2024-02-17 18:23:09', '2024-02-17 18:23:09', 106, 'beamlak123'),
(522, 60, 1, '2024-02-17 18:23:09', '2024-02-17 18:23:09', 108, 'beamlak123'),
(523, 60, 1, '2024-02-17 18:23:09', '2024-02-17 18:23:09', 107, 'beamlak123'),
(524, 60, 1, '2024-02-17 18:23:09', '2024-02-17 18:23:09', 108, 'beamlak123'),
(525, 60, 1, '2024-02-17 18:29:48', '2024-02-17 18:29:48', 106, 'beamlak123'),
(526, 60, 182, '2024-02-17 18:29:48', '2024-02-17 18:29:48', 107, 'beamlak123'),
(527, 60, 183, '2024-02-17 18:29:48', '2024-02-17 18:29:48', 108, 'beamlak123'),
(528, 60, 1, '2024-02-17 18:50:43', '2024-02-17 18:50:43', 106, 'beamlak123'),
(529, 60, 1, '2024-02-17 18:50:43', '2024-02-17 18:50:43', 107, 'beamlak123'),
(530, 60, 1, '2024-02-17 18:50:43', '2024-02-17 18:50:43', 108, 'beamlak123'),
(531, 60, 179, '2024-02-18 10:07:49', '2024-02-18 10:07:49', 106, 'beamlak'),
(532, 60, 182, '2024-02-18 10:07:49', '2024-02-18 10:07:49', 107, 'beamlak'),
(533, 60, 183, '2024-02-18 10:07:49', '2024-02-18 10:07:49', 108, 'beamlak'),
(534, 60, 1, '2024-02-18 10:10:27', '2024-02-18 10:10:27', 106, 'beamlak'),
(535, 60, 1, '2024-02-18 10:10:27', '2024-02-18 10:10:27', 107, 'beamlak'),
(536, 60, 1, '2024-02-18 10:10:27', '2024-02-18 10:10:27', 108, 'beamlak'),
(537, 60, 1, '2024-02-18 10:31:49', '2024-02-18 10:31:49', 106, 'aschalew'),
(538, 60, 1, '2024-02-18 10:31:49', '2024-02-18 10:31:49', 107, 'aschalew'),
(539, 60, 1, '2024-02-18 10:31:49', '2024-02-18 10:31:49', 108, 'aschalew'),
(540, 60, 1, '2024-02-18 10:35:12', '2024-02-18 10:35:12', 106, 'aschalew'),
(541, 60, 1, '2024-02-18 10:35:12', '2024-02-18 10:35:12', 107, 'aschalew'),
(542, 60, 1, '2024-02-18 10:35:12', '2024-02-18 10:35:12', 108, 'aschalew'),
(543, 60, 178, '2024-02-18 10:40:12', '2024-02-18 10:40:12', 106, 'aschalew'),
(544, 60, 181, '2024-02-18 10:40:13', '2024-02-18 10:40:13', 107, 'aschalew'),
(545, 60, 184, '2024-02-18 10:40:13', '2024-02-18 10:40:13', 108, 'aschalew'),
(546, 60, 178, '2024-02-18 10:46:00', '2024-02-18 10:46:00', 106, 'aschalew'),
(547, 60, 181, '2024-02-18 10:46:00', '2024-02-18 10:46:00', 107, 'aschalew'),
(548, 60, 184, '2024-02-18 10:46:00', '2024-02-18 10:46:00', 108, 'aschalew'),
(549, 60, 1, '2024-02-18 10:47:00', '2024-02-18 10:47:00', 106, 'abelSeyoum'),
(550, 60, 1, '2024-02-18 10:47:00', '2024-02-18 10:47:00', 107, 'abelSeyoum'),
(551, 60, 1, '2024-02-18 10:47:00', '2024-02-18 10:47:00', 108, 'abelSeyoum'),
(552, 60, 178, '2024-02-18 10:48:01', '2024-02-18 10:48:01', 106, 'beamlak'),
(553, 60, 181, '2024-02-18 10:48:01', '2024-02-18 10:48:01', 107, 'beamlak'),
(554, 60, 184, '2024-02-18 10:48:01', '2024-02-18 10:48:01', 108, 'beamlak'),
(555, 60, 1, '2024-02-18 10:48:35', '2024-02-18 10:48:35', 106, 'aschalew'),
(556, 60, 1, '2024-02-18 10:48:35', '2024-02-18 10:48:35', 107, 'aschalew'),
(557, 60, 1, '2024-02-18 10:48:35', '2024-02-18 10:48:35', 108, 'aschalew'),
(558, 60, 1, '2024-02-18 10:50:37', '2024-02-18 10:50:37', 106, 'beamlak'),
(559, 60, 1, '2024-02-18 10:50:37', '2024-02-18 10:50:37', 107, 'beamlak'),
(560, 60, 1, '2024-02-18 10:50:37', '2024-02-18 10:50:37', 108, 'beamlak'),
(561, 60, 1, '2024-02-18 10:56:46', '2024-02-18 10:56:46', 106, 'aschalew'),
(562, 60, 1, '2024-02-18 10:56:46', '2024-02-18 10:56:46', 107, 'aschalew'),
(563, 60, 1, '2024-02-18 10:56:46', '2024-02-18 10:56:46', 108, 'aschalew'),
(564, 60, 1, '2024-02-18 11:05:38', '2024-02-18 11:05:38', 106, 'beamlak'),
(565, 60, 1, '2024-02-18 11:05:38', '2024-02-18 11:05:38', 107, 'beamlak'),
(566, 60, 1, '2024-02-18 11:05:38', '2024-02-18 11:05:38', 108, 'beamlak'),
(567, 60, 1, '2024-02-18 11:05:56', '2024-02-18 11:05:56', 106, 'aschalew'),
(568, 60, 1, '2024-02-18 11:05:56', '2024-02-18 11:05:56', 107, 'aschalew'),
(569, 60, 1, '2024-02-18 11:05:56', '2024-02-18 11:05:56', 108, 'aschalew'),
(570, 60, 1, '2024-02-18 12:54:31', '2024-02-18 12:54:31', 106, 'abelabel'),
(571, 60, 1, '2024-02-18 12:54:31', '2024-02-18 12:54:31', 107, 'abelabel'),
(572, 60, 1, '2024-02-18 12:54:31', '2024-02-18 12:54:31', 108, 'abelabel'),
(573, 60, 1, '2024-02-18 12:59:42', '2024-02-18 12:59:42', 106, 'abelabel'),
(574, 60, 182, '2024-02-18 12:59:42', '2024-02-18 12:59:42', 107, 'abelabel'),
(575, 60, 184, '2024-02-18 12:59:42', '2024-02-18 12:59:42', 108, 'abelabel'),
(576, 60, 178, '2024-02-18 13:03:12', '2024-02-18 13:03:12', 106, 'abelabel'),
(577, 60, 181, '2024-02-18 13:03:12', '2024-02-18 13:03:12', 107, 'abelabel'),
(578, 60, 184, '2024-02-18 13:03:12', '2024-02-18 13:03:12', 108, 'abelabel'),
(579, 60, 178, '2024-02-18 13:04:57', '2024-02-18 13:04:57', 106, 'abel_seyoum'),
(580, 60, 181, '2024-02-18 13:04:57', '2024-02-18 13:04:57', 107, 'abel_seyoum'),
(581, 60, 184, '2024-02-18 13:04:57', '2024-02-18 13:04:57', 108, 'abel_seyoum'),
(582, 60, 1, '2024-02-18 13:07:36', '2024-02-18 13:07:36', 106, 'abel_seyoum'),
(583, 60, 1, '2024-02-18 13:07:36', '2024-02-18 13:07:36', 107, 'abel_seyoum'),
(584, 60, 1, '2024-02-18 13:07:36', '2024-02-18 13:07:36', 108, 'abel_seyoum'),
(585, 60, 1, '2024-02-18 13:12:33', '2024-02-18 13:12:33', 106, 'abel_seyoum'),
(586, 60, 1, '2024-02-18 13:12:33', '2024-02-18 13:12:33', 107, 'abel_seyoum'),
(587, 60, 1, '2024-02-18 13:12:33', '2024-02-18 13:12:33', 108, 'abel_seyoum'),
(588, 60, 178, '2024-02-18 13:13:26', '2024-02-18 13:13:26', 106, 'abelabel'),
(589, 60, 181, '2024-02-18 13:13:26', '2024-02-18 13:13:26', 107, 'abelabel'),
(590, 60, 184, '2024-02-18 13:13:26', '2024-02-18 13:13:26', 108, 'abelabel'),
(591, 60, 178, '2024-02-18 13:15:22', '2024-02-18 13:15:22', 106, 'abel_seyoum'),
(592, 60, 181, '2024-02-18 13:15:22', '2024-02-18 13:15:22', 107, 'abel_seyoum'),
(593, 60, 184, '2024-02-18 13:15:22', '2024-02-18 13:15:22', 108, 'abel_seyoum'),
(594, 60, 1, '2024-02-18 13:15:34', '2024-02-18 13:15:34', 106, 'abelabel'),
(595, 60, 1, '2024-02-18 13:15:34', '2024-02-18 13:15:34', 107, 'abelabel'),
(596, 60, 184, '2024-02-18 13:15:34', '2024-02-18 13:15:34', 108, 'abelabel'),
(597, 60, 1, '2024-02-18 13:18:11', '2024-02-18 13:18:11', 106, 'abelabel'),
(598, 60, 1, '2024-02-18 13:18:11', '2024-02-18 13:18:11', 107, 'abelabel'),
(599, 60, 1, '2024-02-18 13:18:11', '2024-02-18 13:18:11', 108, 'abelabel'),
(600, 60, 1, '2024-02-18 13:18:25', '2024-02-18 13:18:25', 106, 'abel_seyoum'),
(601, 60, 1, '2024-02-18 13:18:25', '2024-02-18 13:18:25', 107, 'abel_seyoum'),
(602, 60, 1, '2024-02-18 13:18:25', '2024-02-18 13:18:25', 108, 'abel_seyoum'),
(603, 60, 178, '2024-02-18 13:21:54', '2024-02-18 13:21:54', 106, 'newuser'),
(604, 60, 181, '2024-02-18 13:21:54', '2024-02-18 13:21:54', 107, 'newuser'),
(605, 60, 184, '2024-02-18 13:21:54', '2024-02-18 13:21:54', 108, 'newuser'),
(606, 60, 1, '2024-02-18 13:28:10', '2024-02-18 13:28:10', 106, 'newuser'),
(607, 60, 1, '2024-02-18 13:28:10', '2024-02-18 13:28:10', 107, 'newuser'),
(608, 60, 1, '2024-02-18 13:28:10', '2024-02-18 13:28:10', 108, 'newuser'),
(609, 60, 178, '2024-02-18 13:45:57', '2024-02-18 13:45:57', 106, 'abel_seyoum'),
(610, 60, 181, '2024-02-18 13:45:57', '2024-02-18 13:45:57', 107, 'abel_seyoum'),
(611, 60, 183, '2024-02-18 13:45:57', '2024-02-18 13:45:57', 108, 'abel_seyoum'),
(612, 60, 178, '2024-02-18 13:55:14', '2024-02-18 13:55:14', 106, 'AbelSy'),
(613, 60, 181, '2024-02-18 13:55:14', '2024-02-18 13:55:14', 107, 'AbelSy'),
(614, 60, 184, '2024-02-18 13:55:14', '2024-02-18 13:55:14', 108, 'AbelSy'),
(615, 60, 178, '2024-02-18 13:55:17', '2024-02-18 13:55:17', 106, 'AbelSe'),
(616, 60, 181, '2024-02-18 13:55:17', '2024-02-18 13:55:17', 107, 'AbelSe'),
(617, 60, 184, '2024-02-18 13:55:17', '2024-02-18 13:55:17', 108, 'AbelSe'),
(618, 60, 1, '2024-02-18 13:57:51', '2024-02-18 13:57:51', 106, 'AbelSy'),
(619, 60, 1, '2024-02-18 13:57:51', '2024-02-18 13:57:51', 107, 'AbelSy'),
(620, 60, 1, '2024-02-18 13:57:51', '2024-02-18 13:57:51', 108, 'AbelSy'),
(621, 60, 1, '2024-02-18 13:59:40', '2024-02-18 13:59:40', 106, 'AbelSe'),
(622, 60, 1, '2024-02-18 13:59:40', '2024-02-18 13:59:40', 107, 'AbelSe'),
(623, 60, 1, '2024-02-18 13:59:40', '2024-02-18 13:59:40', 108, 'AbelSe'),
(624, 60, 178, '2024-02-18 14:10:17', '2024-02-18 14:10:17', 106, 'AbelSe'),
(625, 60, 181, '2024-02-18 14:10:17', '2024-02-18 14:10:17', 107, 'AbelSe'),
(626, 60, 184, '2024-02-18 14:10:17', '2024-02-18 14:10:17', 108, 'AbelSe'),
(627, 60, 178, '2024-02-18 14:12:01', '2024-02-18 14:12:01', 106, 'AbelSe'),
(628, 60, 181, '2024-02-18 14:12:01', '2024-02-18 14:12:01', 107, 'AbelSe'),
(629, 60, 184, '2024-02-18 14:12:01', '2024-02-18 14:12:01', 108, 'AbelSe'),
(630, 60, 178, '2024-02-18 14:25:46', '2024-02-18 14:25:46', 106, 'newusera'),
(631, 60, 181, '2024-02-18 14:25:46', '2024-02-18 14:25:46', 107, 'newusera'),
(632, 60, 184, '2024-02-18 14:25:46', '2024-02-18 14:25:46', 108, 'newusera'),
(633, 60, 1, '2024-02-18 14:28:21', '2024-02-18 14:28:21', 106, 'newusera'),
(634, 60, 1, '2024-02-18 14:28:21', '2024-02-18 14:28:21', 107, 'newusera'),
(635, 60, 1, '2024-02-18 14:28:21', '2024-02-18 14:28:21', 108, 'newusera'),
(636, 60, 178, '2024-02-18 14:29:55', '2024-02-18 14:29:55', 106, 'newuserb'),
(637, 60, 181, '2024-02-18 14:29:55', '2024-02-18 14:29:55', 107, 'newuserb'),
(638, 60, 184, '2024-02-18 14:29:55', '2024-02-18 14:29:55', 108, 'newuserb'),
(639, 60, 178, '2024-02-18 14:33:51', '2024-02-18 14:33:51', 106, 'newuserb'),
(640, 60, 181, '2024-02-18 14:33:51', '2024-02-18 14:33:51', 107, 'newuserb'),
(641, 60, 184, '2024-02-18 14:33:51', '2024-02-18 14:33:51', 108, 'newuserb'),
(642, 60, 178, '2024-02-18 14:35:26', '2024-02-18 14:35:26', 106, 'newuserb'),
(643, 60, 181, '2024-02-18 14:35:26', '2024-02-18 14:35:26', 107, 'newuserb'),
(644, 60, 184, '2024-02-18 14:35:26', '2024-02-18 14:35:26', 108, 'newuserb'),
(645, 60, 178, '2024-02-18 14:36:54', '2024-02-18 14:36:54', 106, 'newuserb'),
(646, 60, 181, '2024-02-18 14:36:54', '2024-02-18 14:36:54', 107, 'newuserb'),
(647, 60, 184, '2024-02-18 14:36:54', '2024-02-18 14:36:54', 108, 'newuserb'),
(648, 60, 178, '2024-02-18 14:38:05', '2024-02-18 14:38:05', 106, 'newuserb'),
(649, 60, 181, '2024-02-18 14:38:05', '2024-02-18 14:38:05', 107, 'newuserb'),
(650, 60, 184, '2024-02-18 14:38:05', '2024-02-18 14:38:05', 108, 'newuserb'),
(651, 60, 1, '2024-02-18 14:40:42', '2024-02-18 14:40:42', 106, 'newuserb'),
(652, 60, 1, '2024-02-18 14:40:42', '2024-02-18 14:40:42', 107, 'newuserb'),
(653, 60, 1, '2024-02-18 14:40:42', '2024-02-18 14:40:42', 108, 'newuserb'),
(654, 60, 178, '2024-02-18 14:41:12', '2024-02-18 14:41:12', 106, 'newuserb'),
(655, 60, 181, '2024-02-18 14:41:12', '2024-02-18 14:41:12', 107, 'newuserb'),
(656, 60, 184, '2024-02-18 14:41:12', '2024-02-18 14:41:12', 108, 'newuserb'),
(657, 60, 1, '2024-02-18 14:42:09', '2024-02-18 14:42:09', 106, 'newusera'),
(658, 60, 1, '2024-02-18 14:42:09', '2024-02-18 14:42:09', 107, 'newusera'),
(659, 60, 1, '2024-02-18 14:42:09', '2024-02-18 14:42:09', 108, 'newusera'),
(660, 60, 178, '2024-02-18 14:42:33', '2024-02-18 14:42:33', 106, 'newuserb'),
(661, 60, 181, '2024-02-18 14:42:33', '2024-02-18 14:42:33', 107, 'newuserb'),
(662, 60, 184, '2024-02-18 14:42:33', '2024-02-18 14:42:33', 108, 'newuserb'),
(663, 60, 1, '2024-02-18 14:44:31', '2024-02-18 14:44:31', 106, 'newusera'),
(664, 60, 1, '2024-02-18 14:44:31', '2024-02-18 14:44:31', 107, 'newusera'),
(665, 60, 1, '2024-02-18 14:44:31', '2024-02-18 14:44:31', 108, 'newusera'),
(666, 60, 178, '2024-02-18 14:44:46', '2024-02-18 14:44:46', 106, 'newuserb'),
(667, 60, 181, '2024-02-18 14:44:46', '2024-02-18 14:44:46', 107, 'newuserb'),
(668, 60, 184, '2024-02-18 14:44:46', '2024-02-18 14:44:46', 108, 'newuserb'),
(669, 60, 1, '2024-02-18 14:46:34', '2024-02-18 14:46:34', 106, 'newuserb'),
(670, 60, 182, '2024-02-18 14:46:34', '2024-02-18 14:46:34', 107, 'newuserb'),
(671, 60, 183, '2024-02-18 14:46:34', '2024-02-18 14:46:34', 108, 'newuserb'),
(672, 60, 178, '2024-02-18 14:48:03', '2024-02-18 14:48:03', 106, 'newuserb'),
(673, 60, 181, '2024-02-18 14:48:03', '2024-02-18 14:48:03', 107, 'newuserb'),
(674, 60, 184, '2024-02-18 14:48:03', '2024-02-18 14:48:03', 108, 'newuserb'),
(675, 60, 1, '2024-02-18 14:49:07', '2024-02-18 14:49:07', 106, 'newusera'),
(676, 60, 1, '2024-02-18 14:49:07', '2024-02-18 14:49:07', 107, 'newusera'),
(677, 60, 1, '2024-02-18 14:49:07', '2024-02-18 14:49:07', 108, 'newusera'),
(678, 60, 178, '2024-02-18 14:50:41', '2024-02-18 14:50:41', 106, 'newuserb'),
(679, 60, 181, '2024-02-18 14:50:41', '2024-02-18 14:50:41', 107, 'newuserb'),
(680, 60, 184, '2024-02-18 14:50:41', '2024-02-18 14:50:41', 108, 'newuserb'),
(681, 60, 1, '2024-02-18 14:51:50', '2024-02-18 14:51:50', 106, 'newusera'),
(682, 60, 1, '2024-02-18 14:51:50', '2024-02-18 14:51:50', 107, 'newusera'),
(683, 60, 1, '2024-02-18 14:51:50', '2024-02-18 14:51:50', 108, 'newusera'),
(684, 60, 1, '2024-02-18 14:54:14', '2024-02-18 14:54:14', 106, 'newusera'),
(685, 60, 1, '2024-02-18 14:54:14', '2024-02-18 14:54:14', 107, 'newusera'),
(686, 60, 1, '2024-02-18 14:54:14', '2024-02-18 14:54:14', 108, 'newusera'),
(687, 60, 178, '2024-02-18 14:54:55', '2024-02-18 14:54:55', 106, 'newuserb'),
(688, 60, 181, '2024-02-18 14:54:55', '2024-02-18 14:54:55', 107, 'newuserb'),
(689, 60, 184, '2024-02-18 14:54:55', '2024-02-18 14:54:55', 108, 'newuserb'),
(690, 60, 1, '2024-02-18 15:00:00', '2024-02-18 15:00:00', 106, 'newuserb'),
(691, 60, 1, '2024-02-18 15:00:00', '2024-02-18 15:00:00', 107, 'newuserb'),
(692, 60, 1, '2024-02-18 15:00:00', '2024-02-18 15:00:00', 108, 'newuserb'),
(693, 60, 1, '2024-02-18 15:09:06', '2024-02-18 15:09:06', 106, 'newusera'),
(694, 60, 1, '2024-02-18 15:09:06', '2024-02-18 15:09:06', 107, 'newusera'),
(695, 60, 1, '2024-02-18 15:09:06', '2024-02-18 15:09:06', 108, 'newusera'),
(696, 60, 1, '2024-02-18 15:18:21', '2024-02-18 15:18:21', 106, 'newuserb'),
(697, 60, 1, '2024-02-18 15:18:21', '2024-02-18 15:18:21', 107, 'newuserb'),
(698, 60, 1, '2024-02-18 15:18:21', '2024-02-18 15:18:21', 108, 'newuserb'),
(699, 60, 1, '2024-02-18 15:23:12', '2024-02-18 15:23:12', 106, 'newuserb'),
(700, 60, 1, '2024-02-18 15:23:12', '2024-02-18 15:23:12', 107, 'newuserb'),
(701, 60, 1, '2024-02-18 15:23:12', '2024-02-18 15:23:12', 108, 'newuserb'),
(702, 60, 1, '2024-02-18 15:23:26', '2024-02-18 15:23:26', 106, 'newusera'),
(703, 60, 1, '2024-02-18 15:23:26', '2024-02-18 15:23:26', 107, 'newusera'),
(704, 60, 1, '2024-02-18 15:23:26', '2024-02-18 15:23:26', 108, 'newusera'),
(705, 60, 1, '2024-02-18 15:31:17', '2024-02-18 15:31:17', 106, 'newuserb'),
(706, 60, 1, '2024-02-18 15:31:17', '2024-02-18 15:31:17', 107, 'newuserb'),
(707, 60, 1, '2024-02-18 15:31:17', '2024-02-18 15:31:17', 108, 'newuserb'),
(708, 60, 178, '2024-02-18 15:36:37', '2024-02-18 15:36:37', 106, 'newusera'),
(709, 60, 181, '2024-02-18 15:36:37', '2024-02-18 15:36:37', 107, 'newusera'),
(710, 60, 184, '2024-02-18 15:36:37', '2024-02-18 15:36:37', 108, 'newusera'),
(711, 60, 1, '2024-02-18 15:37:30', '2024-02-18 15:37:30', 106, 'newuserb'),
(712, 60, 1, '2024-02-18 15:37:30', '2024-02-18 15:37:30', 107, 'newuserb'),
(713, 60, 1, '2024-02-18 15:37:30', '2024-02-18 15:37:30', 108, 'newuserb'),
(714, 60, 1, '2024-02-18 15:39:34', '2024-02-18 15:39:34', 106, 'newusera'),
(715, 60, 1, '2024-02-18 15:39:34', '2024-02-18 15:39:34', 107, 'newusera'),
(716, 60, 1, '2024-02-18 15:39:34', '2024-02-18 15:39:34', 108, 'newusera'),
(717, 60, 1, '2024-02-18 15:50:23', '2024-02-18 15:50:23', 106, 'newuserb'),
(718, 60, 1, '2024-02-18 15:50:23', '2024-02-18 15:50:23', 107, 'newuserb'),
(719, 60, 1, '2024-02-18 15:50:23', '2024-02-18 15:50:23', 108, 'newuserb'),
(720, 60, 1, '2024-02-18 15:56:42', '2024-02-18 15:56:42', 106, 'newuserb'),
(721, 60, 1, '2024-02-18 15:56:42', '2024-02-18 15:56:42', 107, 'newuserb'),
(722, 60, 1, '2024-02-18 15:56:42', '2024-02-18 15:56:42', 108, 'newuserb'),
(723, 60, 1, '2024-02-18 16:00:32', '2024-02-18 16:00:32', 106, 'newuserb'),
(724, 60, 1, '2024-02-18 16:00:32', '2024-02-18 16:00:32', 107, 'newuserb'),
(725, 60, 1, '2024-02-18 16:00:32', '2024-02-18 16:00:32', 108, 'newuserb'),
(726, 60, 1, '2024-02-18 16:02:47', '2024-02-18 16:02:47', 106, 'newuserb'),
(727, 60, 1, '2024-02-18 16:02:47', '2024-02-18 16:02:47', 107, 'newuserb'),
(728, 60, 1, '2024-02-18 16:02:47', '2024-02-18 16:02:47', 108, 'newuserb'),
(729, 60, 1, '2024-02-18 16:06:20', '2024-02-18 16:06:20', 106, 'newusera'),
(730, 60, 1, '2024-02-18 16:06:20', '2024-02-18 16:06:20', 107, 'newusera'),
(731, 60, 1, '2024-02-18 16:06:20', '2024-02-18 16:06:20', 108, 'newusera'),
(732, 60, 1, '2024-02-18 16:13:07', '2024-02-18 16:13:07', 106, 'newusera'),
(733, 60, 1, '2024-02-18 16:13:07', '2024-02-18 16:13:07', 107, 'newusera'),
(734, 60, 1, '2024-02-18 16:13:07', '2024-02-18 16:13:07', 108, 'newusera'),
(735, 60, 1, '2024-02-18 16:13:10', '2024-02-18 16:13:10', 106, 'newuserb'),
(736, 60, 1, '2024-02-18 16:13:10', '2024-02-18 16:13:10', 107, 'newuserb'),
(737, 60, 1, '2024-02-18 16:13:10', '2024-02-18 16:13:10', 108, 'newuserb'),
(738, 60, 1, '2024-02-18 16:13:19', '2024-02-18 16:13:19', 106, 'newusera'),
(739, 60, 1, '2024-02-18 16:13:19', '2024-02-18 16:13:19', 107, 'newusera'),
(740, 60, 1, '2024-02-18 16:13:19', '2024-02-18 16:13:19', 108, 'newusera'),
(741, 60, 1, '2024-02-18 16:17:10', '2024-02-18 16:17:10', 106, 'newusera'),
(742, 60, 1, '2024-02-18 16:17:10', '2024-02-18 16:17:10', 107, 'newusera'),
(743, 60, 1, '2024-02-18 16:17:10', '2024-02-18 16:17:10', 108, 'newusera'),
(744, 60, 1, '2024-02-18 16:17:18', '2024-02-18 16:17:18', 106, 'newuserb'),
(745, 60, 1, '2024-02-18 16:17:18', '2024-02-18 16:17:18', 107, 'newuserb'),
(746, 60, 1, '2024-02-18 16:17:18', '2024-02-18 16:17:18', 108, 'newuserb'),
(747, 60, 1, '2024-02-18 16:43:26', '2024-02-18 16:43:26', 106, 'newuserb'),
(748, 60, 1, '2024-02-18 16:43:26', '2024-02-18 16:43:26', 107, 'newuserb'),
(749, 60, 1, '2024-02-18 16:43:26', '2024-02-18 16:43:26', 108, 'newuserb'),
(750, 60, 1, '2024-02-18 16:45:20', '2024-02-18 16:45:20', 106, 'newusera'),
(751, 60, 1, '2024-02-18 16:45:20', '2024-02-18 16:45:20', 107, 'newusera'),
(752, 60, 1, '2024-02-18 16:45:20', '2024-02-18 16:45:20', 108, 'newusera'),
(753, 60, 178, '2024-02-18 16:48:07', '2024-02-18 16:48:07', 106, 'newuserd'),
(754, 60, 181, '2024-02-18 16:48:07', '2024-02-18 16:48:07', 107, 'newuserd'),
(755, 60, 184, '2024-02-18 16:48:07', '2024-02-18 16:48:07', 108, 'newuserd'),
(756, 60, 1, '2024-02-18 16:48:12', '2024-02-18 16:48:12', 106, 'newuserc'),
(757, 60, 182, '2024-02-18 16:48:12', '2024-02-18 16:48:12', 107, 'newuserc'),
(758, 60, 183, '2024-02-18 16:48:12', '2024-02-18 16:48:12', 108, 'newuserc'),
(759, 60, 1, '2024-02-18 16:53:10', '2024-02-18 16:53:10', 106, 'newuserd'),
(760, 60, 1, '2024-02-18 16:53:10', '2024-02-18 16:53:10', 107, 'newuserd'),
(761, 60, 1, '2024-02-18 16:53:10', '2024-02-18 16:53:10', 108, 'newuserd'),
(762, 60, 1, '2024-02-18 16:57:52', '2024-02-18 16:57:52', 106, 'newuserc'),
(763, 60, 1, '2024-02-18 16:57:52', '2024-02-18 16:57:52', 107, 'newuserc'),
(764, 60, 1, '2024-02-18 16:57:52', '2024-02-18 16:57:52', 108, 'newuserc'),
(765, 60, 1, '2024-02-18 16:59:09', '2024-02-18 16:59:09', 106, 'newuserd'),
(766, 60, 1, '2024-02-18 16:59:09', '2024-02-18 16:59:09', 107, 'newuserd'),
(767, 60, 1, '2024-02-18 16:59:09', '2024-02-18 16:59:09', 108, 'newuserd'),
(768, 60, 178, '2024-02-18 17:03:48', '2024-02-18 17:03:48', 106, 'beamlakk'),
(769, 60, 181, '2024-02-18 17:03:48', '2024-02-18 17:03:48', 107, 'beamlakk'),
(770, 60, 184, '2024-02-18 17:03:48', '2024-02-18 17:03:48', 108, 'beamlakk'),
(771, 60, 1, '2024-02-18 17:04:38', '2024-02-18 17:04:38', 106, 'newuserc'),
(772, 60, 1, '2024-02-18 17:04:38', '2024-02-18 17:04:38', 107, 'newuserc'),
(773, 60, 1, '2024-02-18 17:04:38', '2024-02-18 17:04:38', 108, 'newuserc'),
(774, 60, 1, '2024-02-18 17:04:42', '2024-02-18 17:04:42', 106, 'newuserd'),
(775, 60, 1, '2024-02-18 17:04:42', '2024-02-18 17:04:42', 107, 'newuserd'),
(776, 60, 1, '2024-02-18 17:04:42', '2024-02-18 17:04:42', 108, 'newuserd'),
(777, 60, 1, '2024-02-18 17:07:23', '2024-02-18 17:07:23', 106, 'beamlakk'),
(778, 60, 1, '2024-02-18 17:07:23', '2024-02-18 17:07:23', 107, 'beamlakk'),
(779, 60, 1, '2024-02-18 17:07:23', '2024-02-18 17:07:23', 108, 'beamlakk'),
(780, 60, 1, '2024-02-18 17:08:41', '2024-02-18 17:08:41', 106, 'aschalewt'),
(781, 60, 1, '2024-02-18 17:08:41', '2024-02-18 17:08:41', 107, 'aschalewt'),
(782, 60, 1, '2024-02-18 17:08:41', '2024-02-18 17:08:41', 108, 'aschalewt'),
(783, 60, 1, '2024-02-18 17:24:17', '2024-02-18 17:24:17', 106, 'newuserd'),
(784, 60, 1, '2024-02-18 17:24:17', '2024-02-18 17:24:17', 107, 'newuserd'),
(785, 60, 1, '2024-02-18 17:24:17', '2024-02-18 17:24:17', 108, 'newuserd'),
(786, 60, 1, '2024-02-18 17:25:01', '2024-02-18 17:25:01', 106, 'beamlakk'),
(787, 60, 1, '2024-02-18 17:25:01', '2024-02-18 17:25:01', 107, 'beamlakk'),
(788, 60, 1, '2024-02-18 17:25:01', '2024-02-18 17:25:01', 108, 'beamlakk'),
(789, 60, 1, '2024-02-18 17:26:42', '2024-02-18 17:26:42', 106, 'newuserc'),
(790, 60, 1, '2024-02-18 17:26:42', '2024-02-18 17:26:42', 107, 'newuserc'),
(791, 60, 1, '2024-02-18 17:26:42', '2024-02-18 17:26:42', 108, 'newuserc'),
(792, 60, 1, '2024-02-18 17:31:27', '2024-02-18 17:31:27', 106, 'newuserd'),
(793, 60, 1, '2024-02-18 17:31:27', '2024-02-18 17:31:27', 107, 'newuserd'),
(794, 60, 1, '2024-02-18 17:31:27', '2024-02-18 17:31:27', 108, 'newuserd'),
(795, 60, 1, '2024-02-18 17:33:46', '2024-02-18 17:33:46', 106, 'newuserc'),
(796, 60, 1, '2024-02-18 17:33:46', '2024-02-18 17:33:46', 107, 'newuserc'),
(797, 60, 1, '2024-02-18 17:33:46', '2024-02-18 17:33:46', 108, 'newuserc'),
(798, 60, 178, '2024-02-18 17:43:12', '2024-02-18 17:43:12', 106, 'newuserF'),
(799, 60, 181, '2024-02-18 17:43:12', '2024-02-18 17:43:12', 107, 'newuserF'),
(800, 60, 184, '2024-02-18 17:43:12', '2024-02-18 17:43:12', 108, 'newuserF'),
(801, 60, 1, '2024-02-18 17:43:17', '2024-02-18 17:43:17', 106, 'newuserE'),
(802, 60, 182, '2024-02-18 17:43:17', '2024-02-18 17:43:17', 107, 'newuserE'),
(803, 60, 183, '2024-02-18 17:43:17', '2024-02-18 17:43:17', 108, 'newuserE'),
(804, 60, 1, '2024-02-18 17:43:52', '2024-02-18 17:43:52', 106, 'newuserE'),
(805, 60, 1, '2024-02-18 17:43:52', '2024-02-18 17:43:52', 107, 'newuserE'),
(806, 60, 1, '2024-02-18 17:43:52', '2024-02-18 17:43:52', 108, 'newuserE'),
(807, 60, 1, '2024-02-18 17:44:06', '2024-02-18 17:44:06', 106, 'newuserF'),
(808, 60, 1, '2024-02-18 17:44:06', '2024-02-18 17:44:06', 107, 'newuserF'),
(809, 60, 1, '2024-02-18 17:44:06', '2024-02-18 17:44:06', 108, 'newuserF'),
(810, 60, 1, '2024-02-18 17:49:24', '2024-02-18 17:49:24', 106, 'newuserF'),
(811, 60, 1, '2024-02-18 17:49:24', '2024-02-18 17:49:24', 107, 'newuserF'),
(812, 60, 1, '2024-02-18 17:49:24', '2024-02-18 17:49:24', 108, 'newuserF'),
(813, 60, 178, '2024-02-18 17:50:12', '2024-02-18 17:50:12', 106, 'newuserE'),
(814, 60, 181, '2024-02-18 17:50:12', '2024-02-18 17:50:12', 107, 'newuserE'),
(815, 60, 184, '2024-02-18 17:50:12', '2024-02-18 17:50:12', 108, 'newuserE'),
(816, 60, 1, '2024-02-18 17:52:01', '2024-02-18 17:52:01', 106, 'newuserE'),
(817, 60, 182, '2024-02-18 17:52:01', '2024-02-18 17:52:01', 107, 'newuserE'),
(818, 60, 183, '2024-02-18 17:52:01', '2024-02-18 17:52:01', 108, 'newuserE'),
(819, 60, 178, '2024-02-18 18:02:27', '2024-02-18 18:02:27', 106, 'newuserE'),
(820, 60, 181, '2024-02-18 18:02:27', '2024-02-18 18:02:27', 107, 'newuserE'),
(821, 60, 184, '2024-02-18 18:02:27', '2024-02-18 18:02:27', 108, 'newuserE'),
(822, 60, 178, '2024-02-18 18:03:32', '2024-02-18 18:03:32', 106, 'newuserE'),
(823, 60, 181, '2024-02-18 18:03:32', '2024-02-18 18:03:32', 107, 'newuserE'),
(824, 60, 184, '2024-02-18 18:03:32', '2024-02-18 18:03:32', 108, 'newuserE'),
(825, 60, 1, '2024-02-18 18:03:57', '2024-02-18 18:03:57', 106, 'beamlakk'),
(826, 60, 1, '2024-02-18 18:03:57', '2024-02-18 18:03:57', 107, 'beamlakk'),
(827, 60, 1, '2024-02-18 18:03:57', '2024-02-18 18:03:57', 108, 'beamlakk'),
(828, 60, 1, '2024-02-18 18:04:57', '2024-02-18 18:04:57', 106, 'newuserF'),
(829, 60, 1, '2024-02-18 18:04:57', '2024-02-18 18:04:57', 107, 'newuserF'),
(830, 60, 1, '2024-02-18 18:04:57', '2024-02-18 18:04:57', 108, 'newuserF'),
(831, 60, 1, '2024-02-18 18:05:38', '2024-02-18 18:05:38', 106, 'newuserE'),
(832, 60, 182, '2024-02-18 18:05:38', '2024-02-18 18:05:38', 107, 'newuserE'),
(833, 60, 183, '2024-02-18 18:05:38', '2024-02-18 18:05:38', 108, 'newuserE'),
(834, 60, 1, '2024-02-18 18:09:47', '2024-02-18 18:09:47', 106, 'beamlakk'),
(835, 60, 1, '2024-02-18 18:09:47', '2024-02-18 18:09:47', 107, 'beamlakk'),
(836, 60, 1, '2024-02-18 18:09:47', '2024-02-18 18:09:47', 108, 'beamlakk'),
(837, 60, 1, '2024-02-18 18:19:01', '2024-02-18 18:19:01', 106, 'beamlakk'),
(838, 60, 1, '2024-02-18 18:19:01', '2024-02-18 18:19:01', 107, 'beamlakk'),
(839, 60, 1, '2024-02-18 18:19:01', '2024-02-18 18:19:01', 108, 'beamlakk'),
(840, 60, 1, '2024-02-18 18:20:56', '2024-02-18 18:20:56', 106, 'beamlakk'),
(841, 60, 1, '2024-02-18 18:20:56', '2024-02-18 18:20:56', 107, 'beamlakk'),
(842, 60, 1, '2024-02-18 18:20:56', '2024-02-18 18:20:56', 108, 'beamlakk'),
(843, 60, 1, '2024-02-18 18:25:05', '2024-02-18 18:25:05', 106, 'beamlakk');
INSERT INTO `answers` (`id`, `window_id`, `choice_id`, `created_at`, `updated_at`, `questions_id`, `user_username`) VALUES
(844, 60, 1, '2024-02-18 18:25:06', '2024-02-18 18:25:06', 107, 'beamlakk'),
(845, 60, 1, '2024-02-18 18:25:06', '2024-02-18 18:25:06', 108, 'beamlakk'),
(846, 60, 1, '2024-02-18 18:51:45', '2024-02-18 18:51:45', 106, 'newuserE'),
(847, 60, 1, '2024-02-18 18:51:45', '2024-02-18 18:51:45', 107, 'newuserE'),
(848, 60, 1, '2024-02-18 18:51:45', '2024-02-18 18:51:45', 108, 'newuserE'),
(849, 60, 1, '2024-02-18 18:55:58', '2024-02-18 18:55:58', 106, 'newuserF'),
(850, 60, 1, '2024-02-18 18:55:58', '2024-02-18 18:55:58', 107, 'newuserF'),
(851, 60, 1, '2024-02-18 18:55:58', '2024-02-18 18:55:58', 108, 'newuserF'),
(852, 60, 1, '2024-02-18 19:13:04', '2024-02-18 19:13:04', 106, 'newuserF'),
(853, 60, 1, '2024-02-18 19:13:04', '2024-02-18 19:13:04', 107, 'newuserF'),
(854, 60, 1, '2024-02-18 19:13:04', '2024-02-18 19:13:04', 108, 'newuserF'),
(855, 60, 1, '2024-02-18 19:34:59', '2024-02-18 19:34:59', 106, 'beamlakk'),
(856, 60, 1, '2024-02-18 19:34:59', '2024-02-18 19:34:59', 107, 'beamlakk'),
(857, 60, 1, '2024-02-18 19:34:59', '2024-02-18 19:34:59', 108, 'beamlakk'),
(858, 60, 1, '2024-02-18 19:36:19', '2024-02-18 19:36:19', 106, 'newuserE'),
(859, 60, 1, '2024-02-18 19:36:19', '2024-02-18 19:36:19', 107, 'newuserE'),
(860, 60, 1, '2024-02-18 19:36:19', '2024-02-18 19:36:19', 108, 'newuserE'),
(861, 60, 1, '2024-02-18 19:37:10', '2024-02-18 19:37:10', 106, 'newuserF'),
(862, 60, 1, '2024-02-18 19:37:10', '2024-02-18 19:37:10', 107, 'newuserF'),
(863, 60, 1, '2024-02-18 19:37:10', '2024-02-18 19:37:10', 108, 'newuserF'),
(864, 60, 1, '2024-02-18 19:40:31', '2024-02-18 19:40:31', 106, 'beamlakk'),
(865, 60, 1, '2024-02-18 19:40:31', '2024-02-18 19:40:31', 107, 'beamlakk'),
(866, 60, 1, '2024-02-18 19:40:31', '2024-02-18 19:40:31', 108, 'beamlakk'),
(867, 60, 1, '2024-02-18 19:43:09', '2024-02-18 19:43:09', 106, 'beamlakk'),
(868, 60, 1, '2024-02-18 19:43:09', '2024-02-18 19:43:09', 107, 'beamlakk'),
(869, 60, 1, '2024-02-18 19:43:09', '2024-02-18 19:43:09', 108, 'beamlakk'),
(870, 60, 1, '2024-02-18 19:44:30', '2024-02-18 19:44:30', 106, 'newuserF'),
(871, 60, 1, '2024-02-18 19:44:30', '2024-02-18 19:44:30', 107, 'newuserF'),
(872, 60, 1, '2024-02-18 19:44:30', '2024-02-18 19:44:30', 108, 'newuserF'),
(873, 60, 1, '2024-02-18 19:50:36', '2024-02-18 19:50:36', 106, 'newuserF'),
(874, 60, 1, '2024-02-18 19:50:36', '2024-02-18 19:50:36', 107, 'newuserF'),
(875, 60, 1, '2024-02-18 19:50:36', '2024-02-18 19:50:36', 108, 'newuserF'),
(876, 60, 1, '2024-02-18 20:05:37', '2024-02-18 20:05:37', 106, 'beamlakk'),
(877, 60, 1, '2024-02-18 20:05:37', '2024-02-18 20:05:37', 107, 'beamlakk'),
(878, 60, 1, '2024-02-18 20:05:37', '2024-02-18 20:05:37', 108, 'beamlakk'),
(879, 60, 1, '2024-02-18 20:10:30', '2024-02-18 20:10:30', 106, 'beamlakk'),
(880, 60, 1, '2024-02-18 20:10:30', '2024-02-18 20:10:30', 107, 'beamlakk'),
(881, 60, 1, '2024-02-18 20:10:30', '2024-02-18 20:10:30', 108, 'beamlakk'),
(882, 60, 1, '2024-02-18 20:12:34', '2024-02-18 20:12:34', 106, 'beamlakk'),
(883, 60, 1, '2024-02-18 20:12:34', '2024-02-18 20:12:34', 107, 'beamlakk'),
(884, 60, 1, '2024-02-18 20:12:34', '2024-02-18 20:12:34', 108, 'beamlakk'),
(885, 60, 1, '2024-02-18 20:12:42', '2024-02-18 20:12:42', 106, 'newuserF'),
(886, 60, 1, '2024-02-18 20:12:42', '2024-02-18 20:12:42', 107, 'newuserF'),
(887, 60, 1, '2024-02-18 20:12:42', '2024-02-18 20:12:42', 108, 'newuserF'),
(888, 60, 1, '2024-02-18 20:16:25', '2024-02-18 20:16:25', 106, 'beamlakk'),
(889, 60, 1, '2024-02-18 20:16:25', '2024-02-18 20:16:25', 107, 'beamlakk'),
(890, 60, 1, '2024-02-18 20:16:25', '2024-02-18 20:16:25', 108, 'beamlakk'),
(891, 60, 1, '2024-02-18 20:26:10', '2024-02-18 20:26:10', 106, 'beamlakk'),
(892, 60, 1, '2024-02-18 20:26:10', '2024-02-18 20:26:10', 107, 'beamlakk'),
(893, 60, 1, '2024-02-18 20:26:10', '2024-02-18 20:26:10', 108, 'beamlakk'),
(894, 60, 1, '2024-02-18 20:42:37', '2024-02-18 20:42:37', 106, 'newuserF'),
(895, 60, 1, '2024-02-18 20:42:37', '2024-02-18 20:42:37', 107, 'newuserF'),
(896, 60, 1, '2024-02-18 20:42:37', '2024-02-18 20:42:37', 108, 'newuserF'),
(897, 60, 1, '2024-02-18 20:52:37', '2024-02-18 20:52:37', 106, 'newuserF'),
(898, 60, 1, '2024-02-18 20:52:37', '2024-02-18 20:52:37', 107, 'newuserF'),
(899, 60, 1, '2024-02-18 20:52:37', '2024-02-18 20:52:37', 108, 'newuserF'),
(900, 60, 1, '2024-02-19 10:41:39', '2024-02-19 10:41:39', 106, 'beamlakk'),
(901, 60, 181, '2024-02-19 10:41:39', '2024-02-19 10:41:39', 107, 'beamlakk'),
(902, 60, 184, '2024-02-19 10:41:39', '2024-02-19 10:41:39', 108, 'beamlakk'),
(903, 60, 178, '2024-02-19 10:42:43', '2024-02-19 10:42:43', 106, 'beamlakk'),
(904, 60, 181, '2024-02-19 10:42:43', '2024-02-19 10:42:43', 107, 'beamlakk'),
(905, 60, 184, '2024-02-19 10:42:43', '2024-02-19 10:42:43', 108, 'beamlakk'),
(906, 60, 1, '2024-02-19 14:24:41', '2024-02-19 14:24:41', 106, 'newuserF'),
(907, 60, 1, '2024-02-19 14:24:41', '2024-02-19 14:24:41', 107, 'newuserF'),
(908, 60, 1, '2024-02-19 14:24:41', '2024-02-19 14:24:41', 108, 'newuserF'),
(909, 60, 1, '2024-02-19 14:28:25', '2024-02-19 14:28:25', 106, 'newuserE'),
(910, 60, 1, '2024-02-19 14:28:25', '2024-02-19 14:28:25', 107, 'newuserE'),
(911, 60, 1, '2024-02-19 14:28:25', '2024-02-19 14:28:25', 108, 'newuserE'),
(912, 60, 1, '2024-02-19 14:37:47', '2024-02-19 14:37:47', 106, 'beamlakk'),
(913, 60, 1, '2024-02-19 14:37:47', '2024-02-19 14:37:47', 107, 'beamlakk'),
(914, 60, 1, '2024-02-19 14:37:47', '2024-02-19 14:37:47', 108, 'beamlakk'),
(915, 60, 178, '2024-02-19 14:40:34', '2024-02-19 14:40:34', 106, 'newuserE'),
(916, 60, 181, '2024-02-19 14:40:34', '2024-02-19 14:40:34', 107, 'newuserE'),
(917, 60, 184, '2024-02-19 14:40:34', '2024-02-19 14:40:34', 108, 'newuserE'),
(918, 60, 1, '2024-02-19 14:42:14', '2024-02-19 14:42:14', 106, 'beamlakk'),
(919, 60, 1, '2024-02-19 14:42:14', '2024-02-19 14:42:14', 107, 'beamlakk'),
(920, 60, 1, '2024-02-19 14:42:14', '2024-02-19 14:42:14', 108, 'beamlakk'),
(921, 60, 1, '2024-02-19 14:42:58', '2024-02-19 14:42:58', 106, 'newuserF'),
(922, 60, 1, '2024-02-19 14:42:58', '2024-02-19 14:42:58', 107, 'newuserF'),
(923, 60, 1, '2024-02-19 14:42:58', '2024-02-19 14:42:58', 108, 'newuserF'),
(924, 60, 1, '2024-02-19 14:43:10', '2024-02-19 14:43:10', 106, 'newuserE'),
(925, 60, 1, '2024-02-19 14:43:10', '2024-02-19 14:43:10', 107, 'newuserE'),
(926, 60, 1, '2024-02-19 14:43:10', '2024-02-19 14:43:10', 108, 'newuserE'),
(927, 60, 1, '2024-02-19 14:45:23', '2024-02-19 14:45:23', 106, 'beamlakk'),
(928, 60, 1, '2024-02-19 14:45:23', '2024-02-19 14:45:23', 107, 'beamlakk'),
(929, 60, 1, '2024-02-19 14:45:23', '2024-02-19 14:45:23', 108, 'beamlakk'),
(930, 60, 1, '2024-02-19 20:16:52', '2024-02-19 20:16:52', 106, 'newuserE'),
(931, 60, 1, '2024-02-19 20:16:52', '2024-02-19 20:16:52', 107, 'newuserE'),
(932, 60, 1, '2024-02-19 20:16:52', '2024-02-19 20:16:52', 108, 'newuserE'),
(933, 60, 1, '2024-02-19 20:19:33', '2024-02-19 20:19:33', 106, 'newuserE'),
(934, 60, 1, '2024-02-19 20:19:33', '2024-02-19 20:19:33', 107, 'newuserE'),
(935, 60, 1, '2024-02-19 20:19:33', '2024-02-19 20:19:33', 108, 'newuserE'),
(936, 60, 1, '2024-02-19 20:24:33', '2024-02-19 20:24:33', 106, 'newuserF'),
(937, 60, 1, '2024-02-19 20:24:33', '2024-02-19 20:24:33', 107, 'newuserF'),
(938, 60, 1, '2024-02-19 20:24:33', '2024-02-19 20:24:33', 108, 'newuserF'),
(939, 60, 1, '2024-02-19 20:34:29', '2024-02-19 20:34:29', 106, 'amanuel'),
(940, 60, 1, '2024-02-19 20:34:29', '2024-02-19 20:34:29', 107, 'amanuel'),
(941, 60, 1, '2024-02-19 20:34:29', '2024-02-19 20:34:29', 108, 'amanuel'),
(942, 60, 1, '2024-02-19 20:40:31', '2024-02-19 20:40:31', 106, 'amanuel'),
(943, 60, 1, '2024-02-19 20:40:31', '2024-02-19 20:40:31', 107, 'amanuel'),
(944, 60, 1, '2024-02-19 20:40:31', '2024-02-19 20:40:31', 108, 'amanuel'),
(945, 60, 1, '2024-02-19 20:48:35', '2024-02-19 20:48:35', 106, 'amanuel'),
(946, 60, 1, '2024-02-19 20:48:35', '2024-02-19 20:48:35', 107, 'amanuel'),
(947, 60, 1, '2024-02-19 20:48:35', '2024-02-19 20:48:35', 108, 'amanuel'),
(948, 60, 1, '2024-02-19 20:50:47', '2024-02-19 20:50:47', 106, 'newuserF'),
(949, 60, 1, '2024-02-19 20:50:47', '2024-02-19 20:50:47', 107, 'newuserF'),
(950, 60, 1, '2024-02-19 20:50:47', '2024-02-19 20:50:47', 108, 'newuserF'),
(951, 60, 1, '2024-02-19 20:52:11', '2024-02-19 20:52:11', 106, 'amanuel'),
(952, 60, 1, '2024-02-19 20:52:11', '2024-02-19 20:52:11', 107, 'amanuel'),
(953, 60, 1, '2024-02-19 20:52:11', '2024-02-19 20:52:11', 108, 'amanuel'),
(954, 60, 1, '2024-02-19 21:05:58', '2024-02-19 21:05:58', 106, 'newuserE'),
(955, 60, 1, '2024-02-19 21:05:58', '2024-02-19 21:05:58', 107, 'newuserE'),
(956, 60, 1, '2024-02-19 21:05:58', '2024-02-19 21:05:58', 108, 'newuserE'),
(957, 60, 1, '2024-02-19 21:06:36', '2024-02-19 21:06:36', 106, 'newuserF'),
(958, 60, 182, '2024-02-19 21:06:36', '2024-02-19 21:06:36', 107, 'newuserF'),
(959, 60, 183, '2024-02-19 21:06:36', '2024-02-19 21:06:36', 108, 'newuserF'),
(960, 60, 1, '2024-02-19 21:17:44', '2024-02-19 21:17:44', 106, 'newuserF'),
(961, 60, 1, '2024-02-19 21:17:44', '2024-02-19 21:17:44', 107, 'newuserF'),
(962, 60, 1, '2024-02-19 21:17:44', '2024-02-19 21:17:44', 108, 'newuserF'),
(963, 60, 1, '2024-02-19 21:18:04', '2024-02-19 21:18:04', 106, 'newuserF'),
(964, 60, 1, '2024-02-19 21:18:04', '2024-02-19 21:18:04', 107, 'newuserF'),
(965, 60, 1, '2024-02-19 21:18:04', '2024-02-19 21:18:04', 108, 'newuserF'),
(966, 60, 1, '2024-02-19 21:28:24', '2024-02-19 21:28:24', 106, 'newuserF'),
(967, 60, 1, '2024-02-19 21:28:24', '2024-02-19 21:28:24', 107, 'newuserF'),
(968, 60, 1, '2024-02-19 21:28:24', '2024-02-19 21:28:24', 108, 'newuserF'),
(969, 60, 1, '2024-02-19 21:30:18', '2024-02-19 21:30:18', 106, 'newuserE'),
(970, 60, 1, '2024-02-19 21:30:18', '2024-02-19 21:30:18', 107, 'newuserE'),
(971, 60, 1, '2024-02-19 21:30:18', '2024-02-19 21:30:18', 108, 'newuserE'),
(972, 60, 1, '2024-02-19 21:45:48', '2024-02-19 21:45:48', 106, 'newuserE'),
(973, 60, 1, '2024-02-19 21:45:48', '2024-02-19 21:45:48', 107, 'newuserE'),
(974, 60, 1, '2024-02-19 21:45:48', '2024-02-19 21:45:48', 108, 'newuserE'),
(975, 60, 1, '2024-02-20 08:21:35', '2024-02-20 08:21:35', 106, 'heruyd@1'),
(976, 60, 1, '2024-02-20 08:21:35', '2024-02-20 08:21:35', 107, 'heruyd@1'),
(977, 60, 1, '2024-02-20 08:21:35', '2024-02-20 08:21:35', 108, 'heruyd@1'),
(978, 60, 177, '2024-02-20 08:23:38', '2024-02-20 08:23:38', 106, 'heruyd@1'),
(979, 60, 181, '2024-02-20 08:23:38', '2024-02-20 08:23:38', 107, 'heruyd@1'),
(980, 60, 183, '2024-02-20 08:23:38', '2024-02-20 08:23:38', 108, 'heruyd@1'),
(981, 60, 178, '2024-02-20 13:13:53', '2024-02-20 13:13:53', 106, 'amanuel'),
(982, 60, 182, '2024-02-20 13:13:53', '2024-02-20 13:13:53', 107, 'amanuel'),
(983, 60, 184, '2024-02-20 13:13:53', '2024-02-20 13:13:53', 108, 'amanuel'),
(984, 60, 1, '2024-02-20 13:14:35', '2024-02-20 13:14:35', 106, 'heruyd@1'),
(985, 60, 1, '2024-02-20 13:14:35', '2024-02-20 13:14:35', 107, 'heruyd@1'),
(986, 60, 1, '2024-02-20 13:14:35', '2024-02-20 13:14:35', 108, 'heruyd@1'),
(987, 60, 1, '2024-02-20 13:17:54', '2024-02-20 13:17:54', 106, 'amanuel'),
(988, 60, 1, '2024-02-20 13:17:54', '2024-02-20 13:17:54', 107, 'amanuel'),
(989, 60, 1, '2024-02-20 13:17:54', '2024-02-20 13:17:54', 108, 'amanuel'),
(990, 60, 1, '2024-02-20 13:19:49', '2024-02-20 13:19:49', 106, 'amanuel'),
(991, 60, 1, '2024-02-20 13:19:49', '2024-02-20 13:19:49', 107, 'amanuel'),
(992, 60, 1, '2024-02-20 13:19:49', '2024-02-20 13:19:49', 108, 'amanuel'),
(993, 60, 1, '2024-02-20 13:45:59', '2024-02-20 13:45:59', 106, 'heruyd@1'),
(994, 60, 1, '2024-02-20 13:45:59', '2024-02-20 13:45:59', 107, 'heruyd@1'),
(995, 60, 1, '2024-02-20 13:45:59', '2024-02-20 13:45:59', 108, 'heruyd@1'),
(996, 60, 1, '2024-02-22 07:38:07', '2024-02-22 07:38:07', 106, 'heruyd@1'),
(997, 60, 1, '2024-02-22 07:38:07', '2024-02-22 07:38:07', 107, 'heruyd@1'),
(998, 60, 1, '2024-02-22 07:38:07', '2024-02-22 07:38:07', 108, 'heruyd@1'),
(999, 60, 1, '2024-02-22 13:59:27', '2024-02-22 13:59:27', 106, 'heruyd1@'),
(1000, 60, 1, '2024-02-22 13:59:27', '2024-02-22 13:59:27', 107, 'heruyd1@'),
(1001, 60, 1, '2024-02-22 13:59:27', '2024-02-22 13:59:27', 108, 'heruyd1@'),
(1002, 60, 1, '2024-02-22 20:28:50', '2024-02-22 20:28:50', 106, 'newuserE'),
(1003, 60, 1, '2024-02-22 20:28:50', '2024-02-22 20:28:50', 107, 'newuserE'),
(1004, 60, 1, '2024-02-22 20:28:50', '2024-02-22 20:28:50', 108, 'newuserE'),
(1005, 60, 1, '2024-02-22 22:19:18', '2024-02-22 22:19:18', 106, 'newusera'),
(1006, 60, 1, '2024-02-22 22:19:18', '2024-02-22 22:19:18', 107, 'newusera'),
(1007, 60, 1, '2024-02-22 22:19:18', '2024-02-22 22:19:18', 108, 'newusera'),
(1008, 60, 1, '2024-02-22 22:20:20', '2024-02-22 22:20:20', 106, 'newusera'),
(1009, 60, 1, '2024-02-22 22:20:20', '2024-02-22 22:20:20', 107, 'newusera'),
(1010, 60, 1, '2024-02-22 22:20:20', '2024-02-22 22:20:20', 108, 'newusera'),
(1011, 60, 178, '2024-02-23 03:01:41', '2024-02-23 03:01:41', 106, 'beamlak'),
(1012, 60, 181, '2024-02-23 03:01:41', '2024-02-23 03:01:41', 107, 'beamlak'),
(1013, 60, 184, '2024-02-23 03:01:41', '2024-02-23 03:01:41', 108, 'beamlak'),
(1014, 60, 1, '2024-02-23 08:32:00', '2024-02-23 08:32:00', 106, 'beamlak'),
(1015, 60, 1, '2024-02-23 08:32:00', '2024-02-23 08:32:00', 107, 'beamlak'),
(1016, 60, 1, '2024-02-23 08:32:00', '2024-02-23 08:32:00', 108, 'beamlak'),
(1017, 60, 178, '2024-02-23 08:33:01', '2024-02-23 08:33:01', 106, 'edelll'),
(1018, 60, 181, '2024-02-23 08:33:01', '2024-02-23 08:33:01', 107, 'edelll'),
(1019, 60, 184, '2024-02-23 08:33:01', '2024-02-23 08:33:01', 108, 'edelll'),
(1020, 60, 1, '2024-02-23 08:34:05', '2024-02-23 08:34:05', 106, 'edelll'),
(1021, 60, 1, '2024-02-23 08:34:05', '2024-02-23 08:34:05', 107, 'edelll'),
(1022, 60, 1, '2024-02-23 08:34:05', '2024-02-23 08:34:05', 108, 'edelll'),
(1023, 60, 178, '2024-02-23 08:34:37', '2024-02-23 08:34:37', 106, 'edelll'),
(1024, 60, 181, '2024-02-23 08:34:37', '2024-02-23 08:34:37', 107, 'edelll'),
(1025, 60, 184, '2024-02-23 08:34:37', '2024-02-23 08:34:37', 108, 'edelll'),
(1026, 60, 177, '2024-02-23 08:35:49', '2024-02-23 08:35:49', 106, 'edelll'),
(1027, 60, 182, '2024-02-23 08:35:49', '2024-02-23 08:35:49', 107, 'edelll'),
(1028, 60, 183, '2024-02-23 08:35:49', '2024-02-23 08:35:49', 108, 'edelll'),
(1029, 60, 1, '2024-02-23 12:06:50', '2024-02-23 12:06:50', 106, 'newuserb'),
(1030, 60, 1, '2024-02-23 12:06:50', '2024-02-23 12:06:50', 107, 'newuserb'),
(1031, 60, 1, '2024-02-23 12:06:50', '2024-02-23 12:06:50', 108, 'newuserb'),
(1032, 60, 1, '2024-02-23 12:07:21', '2024-02-23 12:07:21', 106, 'newuserb'),
(1033, 60, 1, '2024-02-23 12:07:21', '2024-02-23 12:07:21', 107, 'newuserb'),
(1034, 60, 1, '2024-02-23 12:07:21', '2024-02-23 12:07:21', 108, 'newuserb'),
(1035, 60, 1, '2024-02-23 12:12:22', '2024-02-23 12:12:22', 106, 'newuserb'),
(1036, 60, 1, '2024-02-23 12:12:22', '2024-02-23 12:12:22', 107, 'newuserb'),
(1037, 60, 1, '2024-02-23 12:12:22', '2024-02-23 12:12:22', 108, 'newuserb'),
(1038, 60, 1, '2024-02-23 12:32:18', '2024-02-23 12:32:18', 106, 'newuserb'),
(1039, 60, 1, '2024-02-23 12:32:18', '2024-02-23 12:32:18', 107, 'newuserb'),
(1040, 60, 1, '2024-02-23 12:32:18', '2024-02-23 12:32:18', 108, 'newuserb'),
(1041, 60, 1, '2024-02-23 12:32:21', '2024-02-23 12:32:21', 106, 'newuserb'),
(1042, 60, 1, '2024-02-23 12:32:21', '2024-02-23 12:32:21', 107, 'newuserb'),
(1043, 60, 1, '2024-02-23 12:32:21', '2024-02-23 12:32:21', 108, 'newuserb'),
(1044, 60, 1, '2024-02-23 16:56:14', '2024-02-23 16:56:14', 106, 'newuserb'),
(1045, 60, 1, '2024-02-23 16:56:14', '2024-02-23 16:56:14', 107, 'newuserb'),
(1046, 60, 1, '2024-02-23 16:56:14', '2024-02-23 16:56:14', 108, 'newuserb'),
(1047, 60, 1, '2024-02-23 16:56:20', '2024-02-23 16:56:20', 106, 'newuserb'),
(1048, 60, 1, '2024-02-23 16:56:20', '2024-02-23 16:56:20', 107, 'newuserb'),
(1049, 60, 1, '2024-02-23 16:56:20', '2024-02-23 16:56:20', 108, 'newuserb'),
(1050, 60, 178, '2024-02-23 20:00:10', '2024-02-23 20:00:10', 106, 'amanaman'),
(1051, 60, 182, '2024-02-23 20:00:10', '2024-02-23 20:00:10', 107, 'amanaman'),
(1052, 60, 183, '2024-02-23 20:00:10', '2024-02-23 20:00:10', 108, 'amanaman'),
(1053, 60, 1, '2024-02-23 20:02:51', '2024-02-23 20:02:51', 106, 'amanaman'),
(1054, 60, 1, '2024-02-23 20:02:51', '2024-02-23 20:02:51', 107, 'amanaman'),
(1055, 60, 1, '2024-02-23 20:02:51', '2024-02-23 20:02:51', 108, 'amanaman'),
(1056, 60, 1, '2024-02-24 07:20:00', '2024-02-24 07:20:00', 106, 'heruyd1@'),
(1057, 60, 1, '2024-02-24 07:20:00', '2024-02-24 07:20:00', 107, 'heruyd1@'),
(1058, 60, 1, '2024-02-24 07:20:00', '2024-02-24 07:20:00', 108, 'heruyd1@'),
(1059, 60, 1, '2024-02-24 07:20:01', '2024-02-24 07:20:01', 106, 'heruyd1@'),
(1060, 60, 1, '2024-02-24 07:20:01', '2024-02-24 07:20:01', 107, 'heruyd1@'),
(1061, 60, 1, '2024-02-24 07:20:01', '2024-02-24 07:20:01', 108, 'heruyd1@'),
(1062, 60, 1, '2024-02-24 14:09:31', '2024-02-24 14:09:31', 106, 'heruyd1@'),
(1063, 60, 1, '2024-02-24 14:09:31', '2024-02-24 14:09:31', 107, 'heruyd1@'),
(1064, 60, 1, '2024-02-24 14:09:31', '2024-02-24 14:09:31', 108, 'heruyd1@'),
(1065, 60, 1, '2024-02-25 13:28:25', '2024-02-25 13:28:25', 106, 'heruyd1@'),
(1066, 60, 1, '2024-02-25 13:28:25', '2024-02-25 13:28:25', 107, 'heruyd1@'),
(1067, 60, 1, '2024-02-25 13:28:25', '2024-02-25 13:28:25', 108, 'heruyd1@'),
(1068, 60, 177, '2024-02-26 08:04:03', '2024-02-26 08:04:03', 106, 'heruyd1@'),
(1069, 60, 182, '2024-02-26 08:04:03', '2024-02-26 08:04:03', 107, 'heruyd1@'),
(1070, 60, 183, '2024-02-26 08:04:03', '2024-02-26 08:04:03', 108, 'heruyd1@'),
(1071, 60, 1, '2024-02-27 07:11:57', '2024-02-27 07:11:57', 106, 'hannibal'),
(1072, 60, 1, '2024-02-27 07:11:57', '2024-02-27 07:11:57', 107, 'hannibal'),
(1073, 60, 1, '2024-02-27 07:11:57', '2024-02-27 07:11:57', 108, 'hannibal'),
(1074, 60, 1, '2024-02-27 07:13:24', '2024-02-27 07:13:24', 106, 'hannibal'),
(1075, 60, 1, '2024-02-27 07:13:24', '2024-02-27 07:13:24', 107, 'hannibal'),
(1076, 60, 1, '2024-02-27 07:13:24', '2024-02-27 07:13:24', 108, 'hannibal'),
(1077, 60, 1, '2024-02-27 09:05:11', '2024-02-27 09:05:11', 106, 'hannibal'),
(1078, 60, 1, '2024-02-27 09:05:11', '2024-02-27 09:05:11', 107, 'hannibal'),
(1079, 60, 183, '2024-02-27 09:05:11', '2024-02-27 09:05:11', 108, 'hannibal'),
(1080, 60, 1, '2024-02-27 10:11:26', '2024-02-27 10:11:26', 106, 'hannibal'),
(1081, 60, 1, '2024-02-27 10:11:26', '2024-02-27 10:11:26', 107, 'hannibal'),
(1082, 60, 1, '2024-02-27 10:11:26', '2024-02-27 10:11:26', 108, 'hannibal');

-- --------------------------------------------------------

--
-- Table structure for table `choices`
--

CREATE TABLE `choices` (
  `id` int NOT NULL,
  `choice` varchar(45) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `questions_id` int NOT NULL,
  `image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `choices`
--

INSERT INTO `choices` (`id`, `choice`, `created_at`, `updated_at`, `questions_id`, `image`) VALUES
(403, 'c1', '2024-03-12 21:47:22', '2024-03-12 21:47:22', 218, 'questions[0][choices][0][image]-1710280042620.jpeg'),
(404, 'c2', '2024-03-12 21:47:22', '2024-03-12 21:47:22', 218, 'questions[0][choices][1][image]-1710280042620.jpeg');

-- --------------------------------------------------------

--
-- Table structure for table `conversation`
--

CREATE TABLE `conversation` (
  `user-1` varchar(45) NOT NULL,
  `user-2` varchar(45) DEFAULT NULL,
  `conversation-id` int NOT NULL,
  `status` enum('new','open','reject') NOT NULL DEFAULT 'new',
  `created-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `custom-questions`
--

CREATE TABLE `custom-questions` (
  `id` int NOT NULL,
  `question-text` varchar(200) NOT NULL,
  `checked` tinyint NOT NULL DEFAULT '0',
  `accepted` tinyint NOT NULL DEFAULT '0',
  `created-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_username` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `deleted-profile-images`
--

CREATE TABLE `deleted-profile-images` (
  `id` int NOT NULL,
  `image` varchar(300) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_username` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `deleted-profile-images`
--

INSERT INTO `deleted-profile-images` (`id`, `image`, `created_at`, `user_username`) VALUES
(16, 'profileImage-1709014283030.jpg', '2024-02-27 07:25:32', 'hannibal'),
(17, 'profileImage-1709014285008.jpg', '2024-02-27 07:25:33', 'hannibal');

-- --------------------------------------------------------

--
-- Table structure for table `device-id`
--

CREATE TABLE `device-id` (
  `username` varchar(45) NOT NULL,
  `deviceId` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `device-id`
--

INSERT INTO `device-id` (`username`, `deviceId`) VALUES
('AbelMaireg', 'cg1hcfOxTO2WUusXy83rsu:APA91bEFDzeEbrggs0WkTxRabvNU_tZzwJJon5rD0uuDXduVoII0HMGoMSI9BdiZvaGxGn2Px0hw6k_2kwLr_JAFa54CoGFxefvyvnQR7FgYXmUcNlVnO_gO3ZBQGO5Q_LFEpb8W654I'),
('abelseyoum', 'dBo48hpJQxis9j6IhbXXak:APA91bGRI_UB11ERgEKfJR-9Vsa1jBop1a7VfFsun56kIHh3-i928XmKYqvy6zuJGWa-jdJIVtXU-U13XZg5pLzNy48uUd4S3Y1tRWcdQz2eDA2WdSMo1aGZg8msFyH6dMgYxS-MY3j4'),
('amanaman', 'cMBQERuPQ7yJmF06pv0WEQ:APA91bGVUl1n4Piuj5ANU4Ys3NL3SLV0ol56E206buGAGkHu4ECIEB-5fbs7X5JqYZOSUaeWuzaMJXeUhAN-W38xMy358-228rnFQYK8aN0U22q7OpStNsQmYxk4nICWvuIjg9l8Kgse'),
('beamlak', 'fXxqpqbJT9GeS9V5eFuqBt:APA91bE0vSVK2j6fSM7cIi6u4N8Kze9jCONc_s5KLUsaotZSHHFfNAHBu3YsDLf1vilRayON0fTuV4UEk_Jy_FtKGMqe83SwLeqtV2GnlumfdT0Rxs3wyTQSLQ_AAxpfJSSZXmyylpfJ');

-- --------------------------------------------------------

--
-- Table structure for table `edited-message`
--

CREATE TABLE `edited-message` (
  `conversation-id` int NOT NULL,
  `message-id` int NOT NULL,
  `username` varchar(45) NOT NULL,
  `new-message` varchar(999) NOT NULL,
  `edit-type` enum('e','d') NOT NULL DEFAULT 'e',
  `created-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `kindOfPerson`
--

CREATE TABLE `kindOfPerson` (
  `username` varchar(45) NOT NULL,
  `type` int NOT NULL,
  `value` tinyint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `conversation-id` int NOT NULL,
  `id-messages` int NOT NULL,
  `sender` varchar(45) NOT NULL,
  `message` varchar(999) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `message-received` tinyint NOT NULL DEFAULT '0',
  `marked-as-read` tinyint NOT NULL DEFAULT '0',
  `created-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT;

--
-- Triggers `message`
--
DELIMITER $$
CREATE TRIGGER `message_AFTER_DELETE` AFTER DELETE ON `message` FOR EACH ROW BEGIN
	DECLARE v_receiver VARCHAR(45);
	CALL GetOtherParticipant(OLD.`conversation-id`, OLD.`sender`, v_receiver);
    
	INSERT INTO `edited-message`
		(`conversation-id`, `message-id`, `username`, `new-message`, `edit-type`)
    VALUES
		(OLD.`conversation-id`, OLD.`id-messages`, v_receiver, "", "d")
	ON DUPLICATE KEY 
		UPDATE `new-message` = "", `edit-type` = "d";
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pd-rcv-ans`
--

CREATE TABLE `pd-rcv-ans` (
  `user` varchar(45) NOT NULL,
  `question-id` int NOT NULL,
  `answer` varchar(200) NOT NULL,
  `created-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `pd-rcv-que`
--

CREATE TABLE `pd-rcv-que` (
  `id` int NOT NULL,
  `question` varchar(200) NOT NULL,
  `created-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `pd-rcv-que`
--

INSERT INTO `pd-rcv-que` (`id`, `question`, `created-at`, `updated-at`) VALUES
(1, 'a', '2024-02-18 13:16:59', '2024-02-18 13:16:59'),
(2, 'b', '2024-02-18 13:16:59', '2024-02-18 13:16:59'),
(3, 'c', '2024-02-18 13:17:00', '2024-02-18 13:17:00'),
(4, 'd', '2024-02-18 13:17:00', '2024-02-18 13:17:00'),
(5, 'e', '2024-02-18 13:17:00', '2024-02-18 13:17:00'),
(6, 'f', '2024-02-18 13:17:00', '2024-02-18 13:17:00'),
(7, 'g', '2024-02-18 13:17:00', '2024-02-18 13:17:00'),
(8, 'h', '2024-02-18 13:17:01', '2024-02-18 13:17:01'),
(9, 'i', '2024-02-18 13:17:01', '2024-02-18 13:17:01'),
(10, 'j', '2024-02-18 13:17:01', '2024-02-18 13:17:01'),
(11, 'k', '2024-02-18 13:17:01', '2024-02-18 13:17:01'),
(12, 'l', '2024-02-18 13:17:01', '2024-02-18 13:17:01'),
(13, 'm', '2024-02-18 13:17:02', '2024-02-18 13:17:02'),
(14, 'n', '2024-02-18 13:17:02', '2024-02-18 13:17:02'),
(15, 'o', '2024-02-18 13:17:02', '2024-02-18 13:17:02'),
(16, 'p', '2024-02-18 13:17:02', '2024-02-18 13:17:02'),
(17, 'q', '2024-02-18 13:17:03', '2024-02-18 13:17:03'),
(18, 'r', '2024-02-18 13:17:03', '2024-02-18 13:17:03'),
(19, 's', '2024-02-18 13:17:03', '2024-02-18 13:17:03'),
(20, 't', '2024-02-18 13:17:03', '2024-02-18 13:17:03'),
(21, 'u', '2024-02-18 13:17:03', '2024-02-18 13:17:03'),
(22, 'v', '2024-02-18 13:17:04', '2024-02-18 13:17:04'),
(23, 'w', '2024-02-18 13:17:04', '2024-02-18 13:17:04'),
(24, 'x', '2024-02-18 13:17:04', '2024-02-18 13:17:04'),
(25, 'y', '2024-02-18 13:17:04', '2024-02-18 13:17:04'),
(26, 'z', '2024-02-18 13:17:05', '2024-02-18 13:17:05');

-- --------------------------------------------------------

--
-- Table structure for table `profile-images`
--

CREATE TABLE `profile-images` (
  `id` int NOT NULL,
  `image` varchar(250) NOT NULL,
  `user_username` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `profile-images`
--

INSERT INTO `profile-images` (`id`, `image`, `user_username`, `created_at`, `updated_at`) VALUES
(65, 'profileImage-1706023010292.jpg', 'abel_seyoum', '2024-01-23 16:16:50', '2024-01-23 16:16:50'),
(66, 'profileImage-1706023412348.jpg', 'abel_m', '2024-01-23 16:23:32', '2024-01-23 16:23:32'),
(67, 'profileImage-1706041670746.jpg', 'Heruyd@1', '2024-01-23 21:27:50', '2024-01-23 21:27:50'),
(68, 'profileImage-1706289047711.jpg', 'amanaman', '2024-01-26 18:10:47', '2024-01-26 18:10:47'),
(69, 'profileImage-1706289061743.jpg', 'daemon ', '2024-01-26 18:11:01', '2024-01-26 18:11:01'),
(70, 'profileImage-1706289106126.jpg', 'daemon ', '2024-01-26 18:11:46', '2024-01-26 18:11:46'),
(71, 'profileImage-1706289145404.jpg', 'daemon ', '2024-01-26 18:12:25', '2024-01-26 18:12:25'),
(72, 'profileImage-1706289354612.jpg', 'daemon ', '2024-01-26 18:15:54', '2024-01-26 18:15:54'),
(73, 'profileImage-1706372101029.jpg', 'beamlak', '2024-01-27 17:15:01', '2024-01-27 17:15:01'),
(74, 'profileImage-1706526590026.jpg', 'beamlakasc', '2024-01-29 12:09:50', '2024-01-29 12:09:50'),
(75, 'profileImage-1706528148653.jpg', 'beamlakascc', '2024-01-29 12:35:48', '2024-01-29 12:35:48'),
(76, 'profileImage-1707194772928.jpg', 'heruyd1@', '2024-02-06 05:46:12', '2024-02-06 05:46:12'),
(77, 'profileImage-1707239420797.jpg', 'ebmbma', '2024-02-06 18:10:22', '2024-02-06 18:10:22'),
(78, 'profileImage-1707497559866.jpg', 'beamlak123', '2024-02-09 17:52:39', '2024-02-09 17:52:39'),
(79, 'profileImage-1707497669145.jpg', 'beamlak321', '2024-02-09 17:54:29', '2024-02-09 17:54:29'),
(80, 'profileImage-1707652516426.jpg', 'abelSeyoum', '2024-02-11 12:55:16', '2024-02-11 12:55:16'),
(81, 'profileImage-1708370891416', 'AbelMaireg', '2024-02-19 20:28:11', '2024-02-19 20:28:11'),
(82, 'profileImage-1708371200964.jpg', 'amanuel', '2024-02-19 20:33:21', '2024-02-19 20:33:21'),
(83, 'profileImage-1708371206384.jpg', 'amanuel', '2024-02-19 20:33:26', '2024-02-19 20:33:26'),
(84, 'profileImage-1708375241940.jpg', 'newuserF', '2024-02-19 21:40:43', '2024-02-19 21:40:43'),
(85, 'profileImage-1708375418385.jpg', 'newuserE', '2024-02-19 21:43:38', '2024-02-19 21:43:38'),
(86, 'profileImage-1708375439099.jpg', 'newuserE', '2024-02-19 21:43:59', '2024-02-19 21:43:59'),
(87, 'profileImage-1708413662642.jpg', 'heruyd@1', '2024-02-20 08:21:02', '2024-02-20 08:21:02'),
(88, 'profileImage-1708413666283.jpg', 'heruyd@1', '2024-02-20 08:21:06', '2024-02-20 08:21:06'),
(89, 'profileImage-1708413669140.jpg', 'heruyd@1', '2024-02-20 08:21:09', '2024-02-20 08:21:09'),
(90, 'profileImage-1708413689316.jpg', 'heruyd@1', '2024-02-20 08:21:29', '2024-02-20 08:21:29'),
(91, 'profileImage-1708413704577.jpg', 'heruyd@1', '2024-02-20 08:21:44', '2024-02-20 08:21:44'),
(92, 'profileImage-1708431549721.jpg', 'amanuel', '2024-02-20 13:19:09', '2024-02-20 13:19:09'),
(93, 'profileImage-1708431561337.jpg', 'amanuel', '2024-02-20 13:19:21', '2024-02-20 13:19:21'),
(94, 'profileImage-1708431565028.jpg', 'amanuel', '2024-02-20 13:19:25', '2024-02-20 13:19:25'),
(95, 'profileImage-1708431568744.jpg', 'amanuel', '2024-02-20 13:19:28', '2024-02-20 13:19:28'),
(96, 'profileImage-1708431683513.jpg', 'amanuel', '2024-02-20 13:21:23', '2024-02-20 13:21:23'),
(97, 'profileImage-1708584560262.jpg', 'heruyd1@', '2024-02-22 07:49:20', '2024-02-22 07:49:20'),
(98, 'profileImage-1708636684835.jpg', 'newusera', '2024-02-22 22:18:04', '2024-02-22 22:18:04'),
(99, 'profileImage-1708636725344.jpg', 'newusera', '2024-02-22 22:18:45', '2024-02-22 22:18:45'),
(100, 'profileImage-1708673568665.jpg', 'edelll', '2024-02-23 08:32:48', '2024-02-23 08:32:48'),
(101, 'profileImage-1708673570714.jpg', 'edelll', '2024-02-23 08:32:50', '2024-02-23 08:32:50'),
(102, 'profileImage-1708686344693.jpg', 'newuserb', '2024-02-23 12:05:44', '2024-02-23 12:05:44'),
(103, 'profileImage-1709014279746.jpg', 'hannibal', '2024-02-27 07:11:19', '2024-02-27 07:11:19'),
(106, 'profileImage-1709219261737.jpg', 'amanaman', '2024-02-29 16:07:42', '2024-02-29 16:07:42'),
(107, 'profileImage-1710078271634.jpg', 'anonuser', '2024-03-10 14:44:31', '2024-03-10 14:44:31'),
(108, 'profileImage-1710421055122.jpg', 'anonuser', '2024-03-14 13:57:35', '2024-03-14 13:57:35');

-- --------------------------------------------------------

--
-- Table structure for table `profile-question-answers`
--

CREATE TABLE `profile-question-answers` (
  `id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_username` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `profile-questions_id` int NOT NULL,
  `profile-question-choices_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `profile-question-choices`
--

CREATE TABLE `profile-question-choices` (
  `id` int NOT NULL,
  `choice` varchar(150) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `profile-questions_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `profile-questions`
--

CREATE TABLE `profile-questions` (
  `id` int NOT NULL,
  `question` text NOT NULL,
  `question_value` decimal(2,0) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `profileData`
--

CREATE TABLE `profileData` (
  `username` varchar(45) NOT NULL,
  `emploementStatus` int DEFAULT NULL,
  `rangeOfSearch` double DEFAULT NULL,
  `rightPath` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `id` int NOT NULL,
  `question` varchar(200) NOT NULL,
  `question_value` decimal(10,0) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `windows_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `questions`
--

INSERT INTO `questions` (`id`, `question`, `question_value`, `created_at`, `updated_at`, `windows_id`) VALUES
(218, 'new collections', 5, '2024-03-12 21:47:22', '2024-03-12 21:47:22', 116);

-- --------------------------------------------------------

--
-- Table structure for table `sample-verification-images`
--

CREATE TABLE `sample-verification-images` (
  `id` int NOT NULL,
  `image` varchar(200) NOT NULL,
  `gender` varchar(45) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `sample-verification-images`
--

INSERT INTO `sample-verification-images` (`id`, `image`, `gender`) VALUES
(37, 'image-1710537295046.jpeg', 'F'),
(36, 'image-1710537294183.jpeg', 'F'),
(35, 'image-1709736132859.jpg', 'F'),
(34, 'image-1709736103763.jpg', 'F'),
(33, 'image-1709736053254.jpg', 'M');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `username` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  `gender` enum('M','F') NOT NULL,
  `birthdate` datetime NOT NULL,
  `phone` bigint NOT NULL,
  `password` varchar(60) NOT NULL,
  `bio` varchar(200) DEFAULT NULL,
  `urlProfileImage` json DEFAULT NULL,
  `religion` int NOT NULL,
  `changeOneSelf` int NOT NULL,
  `longitude` double NOT NULL,
  `verified` tinyint NOT NULL DEFAULT '0',
  `latitude` double NOT NULL,
  `created-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`username`, `name`, `gender`, `birthdate`, `phone`, `password`, `bio`, `urlProfileImage`, `religion`, `changeOneSelf`, `longitude`, `verified`, `latitude`, `created-at`, `updated-at`) VALUES
('AbelMaireg', 'Abel Maireg Gebremichael', 'M', '2003-02-06 00:00:00', 251919965444, '$2a$10$Tva5wbiy1TWNS8YmkUfIZedfVHlxXdR.IXoWJnyDSvFC.YzR/.RUa', '...', NULL, 1, 6, 90, 0, 15, '2024-03-10 13:30:01', '2024-03-10 13:30:01'),
('abelseyoum', 'Abel seyoum', 'M', '2008-03-18 00:00:00', 251909090909, '$2a$10$MPYkF4LXUSlMTqPBDx1wB.K5IgsTXIFynJKf6H5rWw7tF588DprGO', 'bio', NULL, 1, 1, -122.084, 0, 37.4219983, '2024-03-14 16:37:27', '2024-03-14 16:37:27'),
('amanaman', 'amanule', 'M', '2008-03-17 00:00:00', 251972285268, '$2a$10$Kt9wnMUN59tdqXZaem7jnu5PJJz8AFngtvAbwLQFcAT6VT3Vh0wpG', 'me', NULL, 1, 2, 38.8814735, 0, 9.0460166, '2024-03-12 21:49:54', '2024-03-12 21:49:54'),
('anonuser', 'anonuser', 'M', '2001-01-01 00:00:00', 251927473727, '$2a$10$G9MpLfd5r31rlm0d8DCtp.2GaaJf2a7DC0bogD33KVWctSNPq3wY.', '.', NULL, 1, 1, 38.6966827, 0, 9.0090284, '2024-03-10 13:44:09', '2024-03-10 13:44:09'),
('beamlak', 'beamlak', 'M', '2001-01-01 00:00:00', 251937167177, '$2a$10$sH1rKudJDuB3Bwd.RETLKeTJjGEOn4TF2VQgOEYU.mnPhrHXDFz.i', '.', NULL, 1, 1, 38.6966826, 0, 9.0090303, '2024-03-10 13:33:19', '2024-03-10 13:33:19'),
('beamlak123', 'beamlak', 'M', '2001-01-01 00:00:00', 251926264663, '$2a$10$sMox/nPJhRmK.W.AzqjR7eNyxc57b7MNBSaCxTvfF3CPpKeYeajZS', '.', NULL, 1, 1, 38.6966827, 0, 9.0090291, '2024-03-10 13:43:25', '2024-03-10 13:43:25');

-- --------------------------------------------------------

--
-- Table structure for table `user-verification-images`
--

CREATE TABLE `user-verification-images` (
  `image` varchar(200) NOT NULL,
  `status` varchar(45) NOT NULL DEFAULT 'pending',
  `user_username` varchar(45) NOT NULL,
  `sample-verification-images_id` int NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `user-verification-images`
--

INSERT INTO `user-verification-images` (`image`, `status`, `user_username`, `sample-verification-images_id`) VALUES
('image-1710404158008.jpg', 'pending', 'anonuser', 76816),
('image-1709477033821.jpeg', 'verified', 'belachew', 25),
('image-1709474752282.jpeg', 'declined', 'belachew', 23);

-- --------------------------------------------------------

--
-- Table structure for table `windows`
--

CREATE TABLE `windows` (
  `id` int NOT NULL,
  `name` varchar(50) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(255) DEFAULT NULL,
  `start_at` datetime NOT NULL,
  `end_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `windows`
--

INSERT INTO `windows` (`id`, `name`, `created_at`, `updated_at`, `status`, `start_at`, `end_at`) VALUES
(116, 'bbbbbbbb', '2024-03-12 22:47:22', '2024-03-12 22:47:22', NULL, '2024-03-07 12:00:00', '2024-02-28 12:00:00');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `answers`
--
ALTER TABLE `answers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_answers_questions1_idx` (`questions_id`),
  ADD KEY `fk_answers_user1_idx` (`user_username`);

--
-- Indexes for table `choices`
--
ALTER TABLE `choices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_choices_questions1_idx` (`questions_id`);

--
-- Indexes for table `conversation`
--
ALTER TABLE `conversation`
  ADD PRIMARY KEY (`conversation-id`),
  ADD KEY `index-user-1-2` (`user-1`,`user-2`),
  ADD KEY `index-user-2-1` (`user-2`,`user-1`);

--
-- Indexes for table `custom-questions`
--
ALTER TABLE `custom-questions`
  ADD PRIMARY KEY (`id`,`user_username`),
  ADD KEY `fk_custom-questions_user1_idx` (`user_username`);

--
-- Indexes for table `deleted-profile-images`
--
ALTER TABLE `deleted-profile-images`
  ADD PRIMARY KEY (`id`,`user_username`),
  ADD KEY `fk_deleted-profile-images_user1_idx` (`user_username`);

--
-- Indexes for table `device-id`
--
ALTER TABLE `device-id`
  ADD PRIMARY KEY (`username`),
  ADD UNIQUE KEY `UNIQUE_deviceId` (`deviceId`) INVISIBLE;

--
-- Indexes for table `edited-message`
--
ALTER TABLE `edited-message`
  ADD PRIMARY KEY (`conversation-id`,`message-id`),
  ADD KEY `fk_message-updates_user1_idx` (`username`);

--
-- Indexes for table `kindOfPerson`
--
ALTER TABLE `kindOfPerson`
  ADD PRIMARY KEY (`username`,`type`);

--
-- Indexes for table `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`conversation-id`,`id-messages`),
  ADD KEY `fk_message_user1_idx` (`sender`);

--
-- Indexes for table `pd-rcv-ans`
--
ALTER TABLE `pd-rcv-ans`
  ADD PRIMARY KEY (`user`,`question-id`),
  ADD KEY `fk_password-recovery-questions_has_user_user1_idx` (`user`);

--
-- Indexes for table `pd-rcv-que`
--
ALTER TABLE `pd-rcv-que`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `profile-images`
--
ALTER TABLE `profile-images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_profile-images_user1_idx` (`user_username`);

--
-- Indexes for table `profile-question-answers`
--
ALTER TABLE `profile-question-answers`
  ADD PRIMARY KEY (`id`,`user_username`,`profile-questions_id`),
  ADD KEY `fk_profile-question-answers_user1_idx` (`user_username`),
  ADD KEY `fk_profile-question-answers_profile-questions1_idx` (`profile-questions_id`),
  ADD KEY `fk_profile-question-answers_profile-question-choices1_idx` (`profile-question-choices_id`);

--
-- Indexes for table `profile-question-choices`
--
ALTER TABLE `profile-question-choices`
  ADD PRIMARY KEY (`id`,`profile-questions_id`),
  ADD KEY `fk_profile-question-choices_profile-questions1_idx` (`profile-questions_id`);

--
-- Indexes for table `profile-questions`
--
ALTER TABLE `profile-questions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `profileData`
--
ALTER TABLE `profileData`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_questions_windows1_idx` (`windows_id`);

--
-- Indexes for table `sample-verification-images`
--
ALTER TABLE `sample-verification-images`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`username`),
  ADD KEY `index_phone` (`phone`) USING BTREE,
  ADD KEY `index_sex` (`gender`),
  ADD KEY `index_created-at` (`created-at` DESC,`updated-at` DESC) INVISIBLE;

--
-- Indexes for table `user-verification-images`
--
ALTER TABLE `user-verification-images`
  ADD PRIMARY KEY (`user_username`,`sample-verification-images_id`),
  ADD KEY `fk_user-verification-images_sample-verification-images1_idx` (`sample-verification-images_id`);

--
-- Indexes for table `windows`
--
ALTER TABLE `windows`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `answers`
--
ALTER TABLE `answers`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1083;

--
-- AUTO_INCREMENT for table `choices`
--
ALTER TABLE `choices`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=465;

--
-- AUTO_INCREMENT for table `conversation`
--
ALTER TABLE `conversation`
  MODIFY `conversation-id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `custom-questions`
--
ALTER TABLE `custom-questions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `deleted-profile-images`
--
ALTER TABLE `deleted-profile-images`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `pd-rcv-que`
--
ALTER TABLE `pd-rcv-que`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `profile-images`
--
ALTER TABLE `profile-images`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=109;

--
-- AUTO_INCREMENT for table `profile-question-answers`
--
ALTER TABLE `profile-question-answers`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `profile-question-choices`
--
ALTER TABLE `profile-question-choices`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `profile-questions`
--
ALTER TABLE `profile-questions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=249;

--
-- AUTO_INCREMENT for table `sample-verification-images`
--
ALTER TABLE `sample-verification-images`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `windows`
--
ALTER TABLE `windows`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=119;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `choices`
--
ALTER TABLE `choices`
  ADD CONSTRAINT `fk_choices_questions1` FOREIGN KEY (`questions_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `conversation`
--
ALTER TABLE `conversation`
  ADD CONSTRAINT `fk_conversation_user1` FOREIGN KEY (`user-1`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_conversation_user2` FOREIGN KEY (`user-2`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `custom-questions`
--
ALTER TABLE `custom-questions`
  ADD CONSTRAINT `fk_custom-questions_user1` FOREIGN KEY (`user_username`) REFERENCES `user` (`username`);

--
-- Constraints for table `deleted-profile-images`
--
ALTER TABLE `deleted-profile-images`
  ADD CONSTRAINT `fk_deleted-profile-images_user1` FOREIGN KEY (`user_username`) REFERENCES `user` (`username`);

--
-- Constraints for table `device-id`
--
ALTER TABLE `device-id`
  ADD CONSTRAINT `fk_table1_user1` FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `edited-message`
--
ALTER TABLE `edited-message`
  ADD CONSTRAINT `fk_message-updates_user1` FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `kindOfPerson`
--
ALTER TABLE `kindOfPerson`
  ADD CONSTRAINT `fk_kindOfPerson_profileData1` FOREIGN KEY (`username`) REFERENCES `profileData` (`username`);

--
-- Constraints for table `message`
--
ALTER TABLE `message`
  ADD CONSTRAINT `fk_Message_Conversatoin_conversaton-id` FOREIGN KEY (`conversation-id`) REFERENCES `conversation` (`conversation-id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_message_user1` FOREIGN KEY (`sender`) REFERENCES `user` (`username`);

--
-- Constraints for table `pd-rcv-ans`
--
ALTER TABLE `pd-rcv-ans`
  ADD CONSTRAINT `fk_password-recovery-questions_has_user_user1` FOREIGN KEY (`user`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `profile-question-answers`
--
ALTER TABLE `profile-question-answers`
  ADD CONSTRAINT `fk_profile-question-answers_profile-question-choices1` FOREIGN KEY (`profile-question-choices_id`) REFERENCES `profile-question-choices` (`id`),
  ADD CONSTRAINT `fk_profile-question-answers_profile-questions1` FOREIGN KEY (`profile-questions_id`) REFERENCES `profile-questions` (`id`),
  ADD CONSTRAINT `fk_profile-question-answers_user1` FOREIGN KEY (`user_username`) REFERENCES `user` (`username`);

--
-- Constraints for table `profile-question-choices`
--
ALTER TABLE `profile-question-choices`
  ADD CONSTRAINT `fk_profile-question-choices_profile-questions1` FOREIGN KEY (`profile-questions_id`) REFERENCES `profile-questions` (`id`);

--
-- Constraints for table `profileData`
--
ALTER TABLE `profileData`
  ADD CONSTRAINT `fk_table1_user2` FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `questions`
--
ALTER TABLE `questions`
  ADD CONSTRAINT `fk_questions_windows1` FOREIGN KEY (`windows_id`) REFERENCES `windows` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
