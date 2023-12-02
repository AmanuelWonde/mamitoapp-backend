-- MySQL Workbench Forward Engineering

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema mamitogw_mamito
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mamitogw_mamito
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mamitogw_mamito` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `mamitogw_mamito` ;

-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`admin`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamitogw_mamito`.`admin` ;

CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`admin` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `creataed-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`windows`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamitogw_mamito`.`windows` ;

CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`windows` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL DEFAULT '0',
  `created-at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`questions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamitogw_mamito`.`questions` ;

CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`questions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `question` VARCHAR(200) NOT NULL,
  `question_value` DECIMAL(2) NOT NULL DEFAULT '0.00',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `windows_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_questions_windows1_idx` (`windows_id` ASC) VISIBLE,
  CONSTRAINT `fk_questions_windows1`
    FOREIGN KEY (`windows_id`)
    REFERENCES `mamitogw_mamito`.`windows` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 36
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamitogw_mamito`.`users` ;

CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`users` (
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
AUTO_INCREMENT = 0
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`answers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamitogw_mamito`.`answers` ;

CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`answers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `window_id` INT NOT NULL,
  `choice_id` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `questions_id` INT NOT NULL,
  `users_username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_answers_questions1_idx` (`questions_id` ASC) VISIBLE,
  INDEX `fk_answers_users1_idx` (`users_username` ASC) VISIBLE)
ENGINE = MyISAM
AUTO_INCREMENT = 36
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`choices`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamitogw_mamito`.`choices` ;

CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`choices` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `choice` VARCHAR(45) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `questions_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_choices_questions1_idx` (`questions_id` ASC) VISIBLE,
  CONSTRAINT `fk_choices_questions1`
    FOREIGN KEY (`questions_id`)
    REFERENCES `mamitogw_mamito`.`questions` (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 43
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`custom-questions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamitogw_mamito`.`custom_questions` ;

CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`custom-questions` (
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
  CONSTRAINT `fk_custom-questions_users1`
    FOREIGN KEY (`users_username`)
    REFERENCES `mamitogw_mamito`.`users` (`username`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`sample-verification-images`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamitogw_mamito`.`sample_verification_images` ;

CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`sample-verification-images` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `image` VARCHAR(200) NOT NULL,
  `sample_for` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`user-verification-images`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mamitogw_mamito`.`user_verification_images` ;

CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`user-verification-images` (
  `image` VARCHAR(200) NOT NULL,
  `sample-verification-images_id` INT NOT NULL,
  `users_username` VARCHAR(45) NOT NULL,
  INDEX `fk_user-verification-images_sample-verification-images1_idx` (`sample-verification-images_id` ASC) VISIBLE,
  PRIMARY KEY (`sample-verification-images_id`, `users_username`),
  CONSTRAINT `fk_user-verification-images_sample-verification-images1`
    FOREIGN KEY (`sample_verification_images_id`)
    REFERENCES `mamitogw_mamito`.`sample_verification_images` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `mamitogw_mamito` ;

-- -----------------------------------------------------
-- procedure CurrentWindowQuestions
-- -----------------------------------------------------

USE `mamitogw_mamito`;
DROP procedure IF EXISTS `mamitogw_mamito`.`CurrentWindowQuestions`;

DELIMITER $$
USE `mamitogw_mamito`$$
CREATE PROCEDURE `CurrentWindowQuestions`(IN `window_id` INT)
BEGIN
    SELECT q.question AS question, q.id AS id,
        JSON_ARRAYAGG(JSON_OBJECT('id', c.id, 'choice', c.choice)) AS choices
    FROM questions q
    LEFT JOIN choices c ON q.id = c.questions_id
    WHERE q.window_id = window_id
    GROUP BY q.id;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertChoice
-- -----------------------------------------------------

USE `mamitogw_mamito`;
DROP procedure IF EXISTS `mamitogw_mamito`.`InsertChoice`;

DELIMITER $$
USE `mamitogw_mamito`$$
CREATE PROCEDURE `InsertChoice`(IN `questionId` INT, IN `choiceValue` VARCHAR(100))
    DETERMINISTIC
BEGIN
    INSERT INTO choices (questions_id, choice)
    VALUES (questionId, choiceValue);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertQuestion
-- -----------------------------------------------------

USE `mamitogw_mamito`;
DROP procedure IF EXISTS `mamitogw_mamito`.`InsertQuestion`;

DELIMITER $$
USE `mamitogw_mamito`$$
CREATE PROCEDURE `InsertQuestion`(IN `question` VARCHAR(100), IN `windowId` INT, IN `value` DECIMAL, OUT `insertedId` INT)
BEGIN
    INSERT INTO questions (question, `value`, window_id)
    VALUES (question, `value`, windowId);
    SET insertedId = LAST_INSERT_ID();
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertUserAnswers
-- -----------------------------------------------------

USE `mamitogw_mamito`;
DROP procedure IF EXISTS `mamitogw_mamito`.`InsertUserAnswers`;

DELIMITER $$
USE `mamitogw_mamito`$$
CREATE PROCEDURE `InsertUserAnswers`(IN `windowId` INT, IN `userName` VARCHAR(255), IN `questionId` INT, IN `choiceId` INT)
BEGIN
    INSERT INTO answers (window_id, users_username, question_id, choice_id)
    VALUES (windowId, userName, questionId, choiceId);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertWindow
-- -----------------------------------------------------

USE `mamitogw_mamito`;
DROP procedure IF EXISTS `mamitogw_mamito`.`InsertWindow`;

DELIMITER $$
USE `mamitogw_mamito`$$
CREATE PROCEDURE `InsertWindow`(IN `name` VARCHAR(50))
BEGIN
    INSERT INTO windows (name)
    VALUES (name);
END$$

DELIMITER ;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
