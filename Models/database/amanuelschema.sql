-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema mamito
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mamito
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mamito` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `mamito` ;

-- -----------------------------------------------------
-- Table `mamito`.`admin`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamito`.`admin` ;

CREATE TABLE IF NOT EXISTS `mamito`.`admin` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `creataed-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamito`.`windows`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamito`.`windows` ;

CREATE TABLE IF NOT EXISTS `mamito`.`windows` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL DEFAULT '0',
  `created-at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamito`.`questions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamito`.`questions` ;

CREATE TABLE IF NOT EXISTS `mamito`.`questions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `question` VARCHAR(200) NOT NULL,
  `question_value` DECIMAL(2,0) NOT NULL DEFAULT '0',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `windows_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_questions_windows1_idx` (`windows_id` ASC) VISIBLE,
  CONSTRAINT `fk_questions_windows1`
    FOREIGN KEY (`windows_id`)
    REFERENCES `mamito`.`windows` (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 52
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamito`.`user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamito`.`user` ;

CREATE TABLE IF NOT EXISTS `mamito`.`user` (
  `username` VARCHAR(45) NOT NULL,
  `sex` ENUM('M', 'F') NOT NULL,
  `birthdate` DATETIME NOT NULL,
  `phone` BIGINT NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `password` VARCHAR(60) NOT NULL,
  `educational-status` ENUM('HS', 'BD', 'MD', 'PS') NULL DEFAULT NULL,
  `employment-status` VARCHAR(45) NULL DEFAULT NULL,
  `bio` VARCHAR(200) NULL DEFAULT NULL,
  `url-profile-image` VARCHAR(200) NULL DEFAULT NULL,
  `religion` VARCHAR(45) NULL DEFAULT NULL,
  `current-location` JSON NULL DEFAULT NULL,
  `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`username`),
  INDEX `index_phone` (`phone` ASC) VISIBLE,
  INDEX `index_sex` (`sex` ASC) VISIBLE,
  INDEX `index_created-at` (`created-at` DESC, `updated-at` DESC) INVISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamito`.`answers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamito`.`answers` ;

CREATE TABLE IF NOT EXISTS `mamito`.`answers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `window_id` INT NOT NULL,
  `choice_id` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `questions_id` INT NOT NULL,
  `user_username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_answers_questions1_idx` (`questions_id` ASC) VISIBLE,
  INDEX `fk_answers_user1_idx` (`user_username` ASC) VISIBLE)
ENGINE = MyISAM
AUTO_INCREMENT = 36
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamito`.`choices`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamito`.`choices` ;

CREATE TABLE IF NOT EXISTS `mamito`.`choices` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `choice` VARCHAR(45) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `questions_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_choices_questions1_idx` (`questions_id` ASC) VISIBLE,
  CONSTRAINT `fk_choices_questions1`
    FOREIGN KEY (`questions_id`)
    REFERENCES `mamito`.`questions` (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 73
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamito`.`custom-questions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamito`.`custom-questions` ;

CREATE TABLE IF NOT EXISTS `mamito`.`custom-questions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `question-text` VARCHAR(200) NOT NULL,
  `checked` TINYINT NOT NULL DEFAULT '0',
  `accepted` TINYINT NOT NULL DEFAULT '0',
  `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `users_id` INT NOT NULL,
  `users_username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`, `users_id`, `users_username`),
  INDEX `fk_custom-questions_users1_idx` (`users_id` ASC, `users_username` ASC) VISIBLE,
  INDEX `fk_custom-questions_users1` (`users_username` ASC) VISIBLE,
  CONSTRAINT `fk_custom-questions_users1`
    FOREIGN KEY (`users_username`)
    REFERENCES `mamito`.`user` (`username`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamito`.`sample-verification-images`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamito`.`sample-verification-images` ;

CREATE TABLE IF NOT EXISTS `mamito`.`sample-verification-images` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `image` VARCHAR(200) NOT NULL,
  `gender` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = MyISAM
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `mamito`.`user-verification-images`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamito`.`user-verification-images` ;

CREATE TABLE IF NOT EXISTS `mamito`.`user-verification-images` (
  `image` VARCHAR(200) NOT NULL,
  `status` VARCHAR(45) NOT NULL DEFAULT 'pending',
  `user_username` VARCHAR(45) NOT NULL,
  `sample-verification-images_id` INT NOT NULL,
  PRIMARY KEY (`user_username`, `sample-verification-images_id`),
  INDEX `fk_user-verification-images_sample-verification-images1_idx` (`sample-verification-images_id` ASC) VISIBLE)
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `mamito` ;

-- -----------------------------------------------------
-- procedure AddVerificationImage
-- -----------------------------------------------------

USE `mamito`;
DROP procedure IF EXISTS `mamito`.`AddVerificationImage`;

DELIMITER $$
USE `mamito`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddVerificationImage`(IN `image` VARCHAR(200), IN `sampleImageId` INT, IN `username` VARCHAR(50))
BEGIN
INSERT INTO user_verification_images(image, sample_verification_images_id, users_username)
VALUES(image, sampleImageId, username);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CurrentWindowQuestions
-- -----------------------------------------------------

USE `mamito`;
DROP procedure IF EXISTS `mamito`.`CurrentWindowQuestions`;

DELIMITER $$
USE `mamito`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CurrentWindowQuestions`(IN `windowId` INT)
BEGIN
    SELECT q.question AS question, q.id AS id,
        JSON_ARRAYAGG(JSON_OBJECT('id', c.id, 'choice', c.choice)) AS choices
    FROM questions q
    LEFT JOIN choices c ON q.id = c.questions_id
    WHERE q.windows_id = windowId
    GROUP BY q.id;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetSampleImages
-- -----------------------------------------------------

USE `mamito`;
DROP procedure IF EXISTS `mamito`.`GetSampleImages`;

DELIMITER $$
USE `mamito`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSampleImages`(IN `inputGender` VARCHAR(50))
BEGIN
    SELECT * FROM sample_verification_images 
    WHERE gender = inputGender;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertChoice
-- -----------------------------------------------------

USE `mamito`;
DROP procedure IF EXISTS `mamito`.`InsertChoice`;

DELIMITER $$
USE `mamito`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertChoice`(IN `questionId` INT, IN `choiceValue` VARCHAR(100))
    DETERMINISTIC
BEGIN
    INSERT INTO choices (questions_id, choice)
    VALUES (questionId, choiceValue);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertQuestion
-- -----------------------------------------------------

USE `mamito`;
DROP procedure IF EXISTS `mamito`.`InsertQuestion`;

DELIMITER $$
USE `mamito`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertQuestion`(IN `question` VARCHAR(100), IN `windowId` INT, IN `questionValue` DECIMAL, OUT `insertedId` INT)
BEGIN
    INSERT INTO questions (question, question_value, windows_id)
    VALUES (question, questionValue, windowId);
    SET insertedId = LAST_INSERT_ID();
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertSampleImage
-- -----------------------------------------------------

USE `mamito`;
DROP procedure IF EXISTS `mamito`.`InsertSampleImage`;

DELIMITER $$
USE `mamito`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertSampleImage`(IN `image` VARCHAR(200), IN `gender` VARCHAR(45))
BEGIN
INSERT INTO sample_verification_images(image, gender)
VALUES (image, gender);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertUserAnswers
-- -----------------------------------------------------

USE `mamito`;
DROP procedure IF EXISTS `mamito`.`InsertUserAnswers`;

DELIMITER $$
USE `mamito`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertUserAnswers`(IN `windowId` INT, IN `userName` VARCHAR(255), IN `questionId` INT, IN `choiceId` INT)
BEGIN
    INSERT INTO answers (window_id, users_username, question_id, choice_id)
    VALUES (windowId, userName, questionId, choiceId);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertWindow
-- -----------------------------------------------------

USE `mamito`;
DROP procedure IF EXISTS `mamito`.`InsertWindow`;

DELIMITER $$
USE `mamito`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertWindow`(IN `name` VARCHAR(50))
BEGIN
    INSERT INTO windows (name)
    VALUES (name);
END$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
