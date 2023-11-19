-- MySQL Workbench Forward Engineering
SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS,
    UNIQUE_CHECKS = 0;
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS,
    FOREIGN_KEY_CHECKS = 0;
SET @OLD_SQL_MODE = @@SQL_MODE,
    SQL_MODE = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
-- -----------------------------------------------------
-- Schema mamito
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mamito`;
-- -----------------------------------------------------
-- Schema mamito
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mamito` DEFAULT CHARACTER SET utf8mb3;
-- -----------------------------------------------------
-- Schema new_schema1
-- -----------------------------------------------------
USE `mamito`;
-- -----------------------------------------------------
-- Table `mamito`.`admin`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`admin` (
    `id-admin` INT NOT NULL AUTO_INCREMENT,
    `creataed-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id-admin`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;
-- -----------------------------------------------------
-- Table `mamito`.`window`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`window` (
    `id-Window` INT NOT NULL AUTO_INCREMENT,
    `views` INT NOT NULL DEFAULT '0',
    `post-date` DATETIME NULL DEFAULT NULL,
    `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id-Window`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;
-- -----------------------------------------------------
-- Table `mamito`.`question`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`question` (
    `id-Question` INT NOT NULL AUTO_INCREMENT,
    `Window-id` INT NOT NULL,
    `question-text` VARCHAR(200) NOT NULL,
    `weigth` DOUBLE NOT NULL,
    `roll-no` INT NOT NULL,
    `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id-Question`, `Window-id`),
    INDEX `fk_Question_Window1_idx` (`Window-id` ASC) INVISIBLE,
    CONSTRAINT `fk_Question_Window1` FOREIGN KEY (`Window-id`) REFERENCES `mamito`.`window` (`id-Window`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;
-- -----------------------------------------------------
-- Table `mamito`.`choice`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`choice` (
    `id-Choice` INT NOT NULL AUTO_INCREMENT,
    `Question-id` INT NOT NULL,
    `Window-id` INT NOT NULL,
    `Choice` VARCHAR(45) NOT NULL,
    `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id-Choice`, `Question-id`, `Window-id`),
    INDEX `fk_Choices-for-Questions_Question1_idx` (`Question-id` ASC, `Window-id` ASC) INVISIBLE,
    CONSTRAINT `fk_Choice_Question1` FOREIGN KEY (`Question-id`, `Window-id`) REFERENCES `mamito`.`question` (`id-Question`, `Window-id`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;
-- -----------------------------------------------------
-- Table `mamito`.`user`
-- -----------------------------------------------------
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
    INDEX `index_phone` (`phone` ASC) INVISIBLE,
    INDEX `index_sex` (`sex` ASC) VISIBLE,
    INDEX `index_created-at` (`created-at` DESC, `updated-at` DESC) VISIBLE
) ENGINE = InnoDB AUTO_INCREMENT = 9 DEFAULT CHARACTER SET = utf8mb3;
-- -----------------------------------------------------
-- Table `mamito`.`answered-questoins`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`answered-questoins` (
    `user-id` VARCHAR(45) NOT NULL,
    `Choice-id` INT NOT NULL,
    `Question-id` INT NOT NULL,
    `Window-id` INT NOT NULL,
    `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`user-id`, `Question-id`, `Window-id`),
    INDEX `fk_Answered-Questoins_Choice1_idx` (
        `Choice-id` ASC,
        `Question-id` ASC,
        `Window-id` ASC
    ) INVISIBLE,
    INDEX `fk_answered-questoins_user1_idx` (`user-id` ASC) VISIBLE,
    CONSTRAINT `fk_Answered-Questoins_Choice1` FOREIGN KEY (`Choice-id`, `Question-id`, `Window-id`) REFERENCES `mamito`.`choice` (`id-Choice`, `Question-id`, `Window-id`),
    CONSTRAINT `fk_answered-questoins_user1` FOREIGN KEY (`user-id`) REFERENCES `mamito`.`user` (`username`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;
-- -----------------------------------------------------
-- Table `mamito`.`conversation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`conversation` (
    `user-1` VARCHAR(45) NOT NULL,
    `user-2` VARCHAR(45) NOT NULL,
    `conversation-id` INT NOT NULL AUTO_INCREMENT,
    `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`user-1`, `user-2`),
    INDEX `fk_conversation_user1_idx` (`user-1` ASC) VISIBLE,
    INDEX `fk_conversation_user2_idx` (`user-2` ASC) VISIBLE,
    UNIQUE INDEX `conversation-id_UNIQUE` (`conversation-id` ASC) INVISIBLE,
    CONSTRAINT `fk_conversation_user1` FOREIGN KEY (`user-1`) REFERENCES `mamito`.`user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_conversation_user2` FOREIGN KEY (`user-2`) REFERENCES `mamito`.`user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;
-- -----------------------------------------------------
-- Table `mamito`.`custom-questions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`custom-questions` (
    `id-custom-questions` INT NOT NULL AUTO_INCREMENT,
    `user` VARCHAR(45) NOT NULL,
    `question-text` VARCHAR(200) NOT NULL,
    `checked` TINYINT NOT NULL DEFAULT '0',
    `accepted` TINYINT NOT NULL DEFAULT '0',
    `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id-custom-questions`, `user`),
    INDEX `fk_custom-questions_user1_idx` (`user` ASC) VISIBLE,
    CONSTRAINT `fk_custom-questions_user1` FOREIGN KEY (`user`) REFERENCES `mamito`.`user` (`username`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;
-- -----------------------------------------------------
-- Table `mamito`.`message`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`message` (
    `id-messages` INT NOT NULL AUTO_INCREMENT,
    `conversation-id` INT NOT NULL,
    `sender` VARCHAR(45) NOT NULL,
    `message` VARCHAR(999) NOT NULL,
    `marked-as-read` TINYINT NOT NULL DEFAULT 0,
    `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id-messages`, `conversation-id`, `sender`),
    INDEX `index_latest` (`conversation-id` DESC, `created-at` DESC) VISIBLE,
    INDEX `fk_message_user1_idx` (`sender` ASC) VISIBLE,
    CONSTRAINT `fk_Message_Conversatoin_conversaton-id` FOREIGN KEY (`conversation-id`) REFERENCES `mamito`.`conversation` (`conversation-id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_message_user1` FOREIGN KEY (`sender`) REFERENCES `mamito`.`user` (`username`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3 ROW_FORMAT = COMPACT;
-- -----------------------------------------------------
-- Table `mamito`.`user-devices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`user-devices` (
    `id-device` INT NOT NULL AUTO_INCREMENT,
    `user` VARCHAR(45) NOT NULL,
    `mac-address` VARCHAR(15) NOT NULL,
    `location` POINT NULL DEFAULT NULL,
    `active` TINYINT NOT NULL,
    `created-at` TIMESTAMP NOT NULL,
    `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id-device`, `user`),
    INDEX `fk_user-devices_user1_idx` (`user` ASC) VISIBLE,
    CONSTRAINT `fk_user-devices_user1` FOREIGN KEY (`user`) REFERENCES `mamito`.`user` (`username`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb3;
USE `mamito`;
-- -----------------------------------------------------
-- procedure GetConversationsForUser
-- -----------------------------------------------------
DELIMITER $$ USE `mamito` $$ CREATE PROCEDURE `GetConversationsForUser`(IN userId INT) BEGIN
SELECT *
FROM Conversation
WHERE `User-id-1` = userId
    OR `User-id-2` = userId;
END $$ DELIMITER;
-- -----------------------------------------------------
-- procedure GetUserByPhone
-- -----------------------------------------------------
DELIMITER $$ USE `mamito` $$ CREATE PROCEDURE `GetUserByPhone`(IN phoneNumber DECIMAL(12, 0)) BEGIN
SELECT *
FROM User
WHERE phone = phoneNumber;
END $$ DELIMITER;
-- -----------------------------------------------------
-- procedure GetUserByUsername
-- -----------------------------------------------------
DELIMITER $$ USE `mamito` $$ CREATE PROCEDURE `GetUserByUsername`(IN user VARCHAR(45)) BEGIN
SELECT *
FROM User
WHERE username = user;
END $$ DELIMITER;
-- -----------------------------------------------------
-- procedure InsertUser
-- -----------------------------------------------------
DELIMITER $$ USE `mamito` $$ CREATE PROCEDURE `InsertUser`(
    IN username VARCHAR(45),
    IN sex ENUM('M', 'F'),
    IN birthdate DATE,
    IN phone DECIMAL(12, 0),
    IN email VARCHAR(45),
    IN password VARCHAR(60),
    IN educationalStatus ENUM('HS', 'BD', 'MD', 'PS'),
    IN employmentStatus VARCHAR(45),
    IN bio VARCHAR(200),
    IN urlProfileImage VARCHAR(200),
    IN religion VARCHAR(45),
    IN currentLocation JSON
) BEGIN
INSERT INTO User (
        `username`,
        `sex`,
        `birthdate`,
        `phone`,
        `email`,
        `password`,
        `educational-status`,
        `employment-status`,
        `bio`,
        `url-profile-image`,
        `religion`,
        `current-location`
    )
VALUES (
        username,
        sex,
        birthdate,
        phone,
        email,
        password,
        educationalStatus,
        employmentStatus,
        bio,
        urlProfileImage,
        religion,
        currentLocation
    );
END $$ DELIMITER;
-- -----------------------------------------------------
-- procedure InsertConversation
-- -----------------------------------------------------
DELIMITER $$ USE `mamito` $$ CREATE PROCEDURE InsertConversation(
    IN p_user1 VARCHAR(45),
    IN p_user2 VARCHAR(45)
) BEGIN
DECLARE user1_count INT;
DECLARE user2_count INT;
SELECT COUNT(*) INTO user1_count
FROM `conversation`
WHERE `user-1` = p_user1
    AND `user-2` = p_user2;
SELECT COUNT(*) INTO user2_count
FROM `conversation`
WHERE `user-1` = p_user2
    AND `user-2` = p_user1;
IF user1_count = 0
AND user2_count = 0 THEN
INSERT INTO `conversation` (`user-1`, `user-2`)
VALUES (p_user1, p_user2);
SELECT LAST_INSERT_ID() AS id_message;
ELSE
SELECT 7002 AS status;
END IF;
END $$ DELIMITER;
-- -----------------------------------------------------
-- procedure DeleteConversation
-- -----------------------------------------------------
DELIMITER $$ USE `mamito` $$ CREATE PROCEDURE `DeleteConversation`(
    IN user1 VARCHAR(45),
    IN user2 VARCHAR(45)
) BEGIN
DELETE FROM `mamito`.`conversation`
WHERE (
        `User-1` = user1
        AND `User-2` = user2
    )
    OR (
        `User-1` = user2
        AND `User-2` = user1
    );
END $$ DELIMITER;
-- -----------------------------------------------------
-- procedure InsertMessage
-- -----------------------------------------------------
DELIMITER $$ USE `mamito` $$ CREATE PROCEDURE InsertMessage(
    IN p_conversation_id INT,
    IN p_sender VARCHAR(45),
    IN p_message VARCHAR(999)
) BEGIN
DECLARE participant_count INT;
SELECT COUNT(*) INTO participant_count
FROM `conversation`
WHERE `conversation-id` = p_conversation_id
    AND (
        `user-1` = p_sender
        OR `user-2` = p_sender
    );
IF participant_count > 0 THEN
INSERT INTO `message` (`conversation-id`, `sender`, `message`)
VALUES (p_conversation_id, p_sender, p_message);
SELECT LAST_INSERT_ID() AS messageId;
ELSE
SELECT 7004 AS status;
END IF;
END $$ DELIMITER;
-- -----------------------------------------------------
-- procedure EditMessageText
-- -----------------------------------------------------
DELIMITER $$ USE `mamito` $$ CREATE PROCEDURE EditMessageText(
    IN p_conversation_id INT,
    IN p_message_id INT,
    IN p_sender VARCHAR(45),
    IN p_new_text VARCHAR(999)
) BEGIN
DECLARE v_sender VARCHAR(45);
SELECT `sender` INTO v_sender
FROM `mamito`.`message`
WHERE `id-Messages` = p_message_id
    AND `conversation-id` = p_conversation_id;
IF v_sender = p_sender THEN
UPDATE `mamito`.`message`
SET `message` = p_new_text,
    `updated-at` = CURRENT_TIMESTAMP
WHERE `id-Messages` = p_message_id
    AND `conversation-id` = p_conversation_id;
SELECT p_new_text AS updatedMessage;
ELSE
SELECT 7005 AS status;
END IF;
END $$ DELIMITER;
-- -----------------------------------------------------
-- procedure GetConversationId
-- -----------------------------------------------------
DELIMITER $$ USE `mamito` $$ CREATE PROCEDURE `GetConversationId` (IN user1 VARCHAR(45), IN user2 VARCHAR(45)) BEGIN
SELECT `conversation-id`
FROM `mamito`.`Conversation`
WHERE `user-1` = user1 && `user-2` = user2;
END $$ DELIMITER;
-- -----------------------------------------------------
-- procedure DeleteMessage
-- -----------------------------------------------------
DELIMITER $$ USE `mamito` $$ CREATE PROCEDURE DeleteMessage(
    IN p_conversation_id INT,
    IN p_message_id INT,
    IN p_sender VARCHAR(45)
) BEGIN
DECLARE v_sender VARCHAR(45);
SELECT `sender` INTO v_sender
FROM `mamito`.`message`
WHERE `conversation-id` = p_conversation_id
    AND `id-Messages` = p_message_id;
IF v_sender IS NOT NULL
AND v_sender = p_sender THEN
DELETE FROM `mamito`.`message`
WHERE `conversation-id` = p_conversation_id
    AND `id-Messages` = p_message_id;
SELECT 1007 AS status;
ELSE
SELECT 7003 AS status;
END IF;
END $$ DELIMITER;
SET SQL_MODE = @OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;