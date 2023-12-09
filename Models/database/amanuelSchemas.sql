-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Dec 09, 2023 at 07:38 AM
-- Server version: 8.0.31
-- PHP Version: 8.0.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mamito`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `AddVerificationImage`$$
CREATE PROCEDURE `AddVerificationImage` (IN `image` VARCHAR(200), IN `sampleImageId` INT, IN `username` VARCHAR(50))   BEGIN
INSERT INTO `user-verification-images`(image, `sample-verification-images_id`, user_username)
VALUES(image, sampleImageId, username);
END$$

DROP PROCEDURE IF EXISTS `CurrentWindowQuestions`$$
CREATE PROCEDURE `CurrentWindowQuestions` (IN `windowId` INT)   BEGIN
    SELECT q.question AS question, q.id AS id, q.question_value AS `value`,
        JSON_ARRAYAGG(JSON_OBJECT('id', c.id, 'choice', c.choice, 'image', c.image)) AS choices
    FROM questions q
    LEFT JOIN choices c ON q.id = c.questions_id
    WHERE q.windows_id = windowId
    GROUP BY q.id;
END$$

DROP PROCEDURE IF EXISTS `FindMatches`$$
CREATE PROCEDURE `FindMatches` (IN `windowId` INT)   BEGIN
SELECT answers.*, `user`.profile_image, questions.value
FROM answers
JOIN `user` ON `user`.username = answers.user_username
JOIN questions ON questions.id = answers.question_id
WHERE answers.window_id = windowId;
END$$

DROP PROCEDURE IF EXISTS `GetCurrentOrNextWindow`$$
CREATE PROCEDURE `GetCurrentOrNextWindow` ()   BEGIN
    DECLARE p_current_window_amount INT;

    SELECT COUNT(*) INTO p_current_window_amount
    FROM `windows`
    WHERE CURRENT_TIMESTAMP BETWEEN `start_at` AND `end_at`;

    IF p_current_window_amount != 0 THEN
        SELECT *
        FROM `windows`
        WHERE CURRENT_TIMESTAMP BETWEEN `start_at` AND `end_at`;
    ELSE
        SELECT *
        FROM `windows`
        WHERE CURRENT_TIMESTAMP <= `start_at`
        ORDER BY `start_at`
        LIMIT 1;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `GetSampleImages`$$
CREATE PROCEDURE `GetSampleImages` (IN `inputGender` VARCHAR(50))   BEGIN
    SELECT * FROM `sample-verification-images` 
    WHERE gender = inputGender;
END$$

DROP PROCEDURE IF EXISTS `GetWindow`$$
CREATE PROCEDURE `GetWindow` ()   BEGIN
SELECT 
id, name, `status`,
    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') AS created_at,
    DATE_FORMAT(start_at, '%Y-%m-%d %H:%i:%s') AS start_at,
    DATE_FORMAT(end_at, '%Y-%m-%d %H:%i:%s') AS end_at 
   FROM windows;
END$$

DROP PROCEDURE IF EXISTS `GetWindowId`$$
CREATE PROCEDURE `GetWindowId` ()   BEGIN
    SELECT *
    FROM windows
    WHERE CURRENT_TIMESTAMP BETWEEN 
    start_at AND
    end_at;
END$$

DROP PROCEDURE IF EXISTS `InsertChoice`$$
CREATE PROCEDURE `InsertChoice` (IN `questionId` INT, IN `choiceValue` VARCHAR(100), IN `image` VARCHAR(255))  DETERMINISTIC BEGIN
    INSERT INTO choices (questions_id, choice, image)
    VALUES (questionId, choiceValue, image);
END$$

DROP PROCEDURE IF EXISTS `InsertQuestion`$$
CREATE PROCEDURE `InsertQuestion` (IN `question` VARCHAR(100), IN `windowId` INT, IN `questionValue` DECIMAL, OUT `insertedId` INT)   BEGIN
    INSERT INTO questions (question, question_value, windows_id)
    VALUES (question, questionValue, windowId);
    SET insertedId = LAST_INSERT_ID();
END$$

DROP PROCEDURE IF EXISTS `InsertSampleImage`$$
CREATE PROCEDURE `InsertSampleImage` (IN `image` VARCHAR(200), IN `gender` VARCHAR(45))   BEGIN
INSERT INTO `sample-verification-images`(image, gender)
VALUES (image, gender);
END$$

DROP PROCEDURE IF EXISTS `InsertUserAnswers`$$
CREATE PROCEDURE `InsertUserAnswers` (IN `windowId` INT, IN `userName` VARCHAR(255), IN `questionId` INT, IN `choiceId` INT)   BEGIN
    INSERT INTO answers (window_id, users_username, question_id, choice_id)
    VALUES (windowId, userName, questionId, choiceId);
END$$

DROP PROCEDURE IF EXISTS `InsertWindow`$$
CREATE PROCEDURE `InsertWindow` (IN `name` VARCHAR(50), IN `startDate` DATETIME, IN `endDate` DATETIME, OUT `insertedId` INT)   BEGIN
    INSERT INTO windows (name, start_at, end_at)
    VALUES (name, startDate, endDate);
      SET insertedId = LAST_INSERT_ID();
END$$

DROP PROCEDURE IF EXISTS `UpdateWindow`$$
CREATE PROCEDURE `UpdateWindow` (IN `windowId` INT, IN `newName` VARCHAR(200), IN `newStartAt` DATETIME, IN `newEndAt` DATETIME)   BEGIN
UPDATE windows
    SET
        name = newName,
        start_at = newStartAt,
        end_at = newEndAt
    WHERE
        id = windowId;
END$$

DROP PROCEDURE IF EXISTS `ValidateUserImages`$$
CREATE PROCEDURE `ValidateUserImages` (IN `validateStatus` VARCHAR(50), IN `username` VARCHAR(50), IN `sampleImageId` INT)   BEGIN
    UPDATE `user-verification-images`
    SET `status` = validateStatus
    WHERE `user-verification-images`.`user_username` = username 
    AND `user-verification-images`.`sample-verification-images_id` = sampleImageId;
END$$

DROP PROCEDURE IF EXISTS `ViewUserVerificationImages`$$
CREATE PROCEDURE `ViewUserVerificationImages` ()   BEGIN
SELECT uvi.`sample-verification-images_id`  AS sampleImageId, uvi.image, uvi.status, uvi.user_username AS username, svi.image AS sampleImage
FROM `user-verification-images` uvi
INNER JOIN `sample-verification-images` svi ON uvi.`sample-verification-images_id` = svi.id
WHERE uvi.status = 'pending';


END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
CREATE TABLE IF NOT EXISTS `admin` (
  `id` int NOT NULL AUTO_INCREMENT,
  `creataed-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `answers`
--

DROP TABLE IF EXISTS `answers`;
CREATE TABLE IF NOT EXISTS `answers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `window_id` int NOT NULL,
  `choice_id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `questions_id` int NOT NULL,
  `user_username` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_answers_questions1_idx` (`questions_id`),
  KEY `fk_answers_user1_idx` (`user_username`)
) ENGINE=MyISAM AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Table structure for table `choices`
--

DROP TABLE IF EXISTS `choices`;
CREATE TABLE IF NOT EXISTS `choices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `choice` varchar(45) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `questions_id` int NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_choices_questions1_idx` (`questions_id`)
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8mb3;



DROP TABLE IF EXISTS `questions`;
CREATE TABLE IF NOT EXISTS `questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question` varchar(200) NOT NULL,
  `question_value` decimal(2,0) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `windows_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_questions_windows1_idx` (`windows_id`)
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=utf8mb3;

-- Table structure for table `sample-verification-images`
--

DROP TABLE IF EXISTS `sample-verification-images`;
CREATE TABLE IF NOT EXISTS `sample-verification-images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `image` varchar(200) NOT NULL,
  `gender` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


--
-- Table structure for table `user-verification-images`
--

DROP TABLE IF EXISTS `user-verification-images`;
CREATE TABLE IF NOT EXISTS `user-verification-images` (
  `image` varchar(200) NOT NULL,
  `status` varchar(45) NOT NULL DEFAULT 'pending',
  `user_username` varchar(45) NOT NULL,
  `sample-verification-images_id` int NOT NULL,
  PRIMARY KEY (`user_username`,`sample-verification-images_id`),
  KEY `fk_user-verification-images_sample-verification-images1_idx` (`sample-verification-images_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
-- --------------------------------------------------------

--
-- Table structure for table `windows`
--

DROP TABLE IF EXISTS `windows`;
CREATE TABLE IF NOT EXISTS `windows` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(255) DEFAULT NULL,
  `start_at` datetime NOT NULL,
  `end_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb3;

-- Constraints for table `choices`
--
ALTER TABLE `choices`
  ADD CONSTRAINT `fk_choices_questions1` FOREIGN KEY (`questions_id`) REFERENCES `questions` (`id`);

--
-- Constraints for table `questions`
--
ALTER TABLE `questions`
  ADD CONSTRAINT `fk_questions_windows1` FOREIGN KEY (`windows_id`) REFERENCES `windows` (`id`);


/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
