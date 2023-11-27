-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mamito
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mamito` ;

-- -----------------------------------------------------
-- Schema mamito
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mamito` DEFAULT CHARACTER SET utf8mb3 ;
-- -----------------------------------------------------
-- Schema new_schema1
-- -----------------------------------------------------
USE `mamito` ;

-- -----------------------------------------------------
-- Table `mamito`.`admin`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`admin` (
  `id-admin` INT NOT NULL AUTO_INCREMENT,
  `creataed-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id-admin`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamito`.`window`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`window` (
  `id-Window` INT NOT NULL AUTO_INCREMENT,
  `views` INT NOT NULL DEFAULT '0',
  `post-date` DATETIME NULL DEFAULT NULL,
  `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id-Window`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


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
  CONSTRAINT `fk_Question_Window1`
    FOREIGN KEY (`Window-id`)
    REFERENCES `mamito`.`window` (`id-Window`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


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
  CONSTRAINT `fk_Choice_Question1`
    FOREIGN KEY (`Question-id` , `Window-id`)
    REFERENCES `mamito`.`question` (`id-Question` , `Window-id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamito`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`user` (
  `username` VARCHAR(45) NOT NULL,
  `gender` ENUM('M', 'F') NOT NULL,
  `birthdate` DATETIME NOT NULL,
  `phone` BIGINT NOT NULL,
  `password` VARCHAR(60) NOT NULL,
  `bio` VARCHAR(200) NOT NULL,
  `urlProfileImage` VARCHAR(200) NULL DEFAULT NULL,
  `religion` INT NOT NULL,
  `changeOneSelf` INT NOT NULL,
  `longitude` DOUBLE NOT NULL,
  `latitude` DOUBLE NOT NULL,
  `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`username`),
  INDEX `index_phone` (`phone` ASC) INVISIBLE,
  INDEX `index_sex` (`gender` ASC) VISIBLE,
  INDEX `index_created-at` (`created-at` DESC, `updated-at` DESC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 9
DEFAULT CHARACTER SET = utf8mb3;


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
  INDEX `fk_Answered-Questoins_Choice1_idx` (`Choice-id` ASC, `Question-id` ASC, `Window-id` ASC) INVISIBLE,
  INDEX `fk_answered-questoins_user1_idx` (`user-id` ASC) VISIBLE,
  CONSTRAINT `fk_Answered-Questoins_Choice1`
    FOREIGN KEY (`Choice-id` , `Question-id` , `Window-id`)
    REFERENCES `mamito`.`choice` (`id-Choice` , `Question-id` , `Window-id`),
  CONSTRAINT `fk_answered-questoins_user1`
    FOREIGN KEY (`user-id`)
    REFERENCES `mamito`.`user` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamito`.`conversation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`conversation` (
  `user-1` VARCHAR(45) NOT NULL,
  `user-2` VARCHAR(45) NOT NULL,
  `conversation-id` INT NOT NULL AUTO_INCREMENT,
  `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`conversation-id`),
  UNIQUE INDEX `index2` (`user-1` ASC, `user-2` ASC) VISIBLE,
  UNIQUE INDEX `index3` (`user-2` ASC, `user-1` ASC) VISIBLE,
  CONSTRAINT `fk_conversation_user1`
    FOREIGN KEY (`user-1` , `user-2`)
    REFERENCES `mamito`.`user` (`username` , `username`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


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
  CONSTRAINT `fk_custom-questions_user1`
    FOREIGN KEY (`user`)
    REFERENCES `mamito`.`user` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


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
  PRIMARY KEY (`conversation-id`, `id-messages`),
  INDEX `index_latest` (`conversation-id` DESC, `created-at` DESC) VISIBLE,
  INDEX `fk_message_user1_idx` (`sender` ASC) VISIBLE,
  CONSTRAINT `fk_Message_Conversatoin_conversaton-id`
    FOREIGN KEY (`conversation-id`)
    REFERENCES `mamito`.`conversation` (`conversation-id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_message_user1`
    FOREIGN KEY (`sender`)
    REFERENCES `mamito`.`user` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3
ROW_FORMAT = COMPACT;


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
  CONSTRAINT `fk_user-devices_user1`
    FOREIGN KEY (`user`)
    REFERENCES `mamito`.`user` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamito`.`updates`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamito`.`updates` (
  `messages-id` INT NOT NULL,
  `conversation-id` INT NOT NULL,
  `sender` VARCHAR(45) NOT NULL,
  `typeOfUpdate` ENUM("new", "edit", "delete") NOT NULL,
  INDEX `fk_updates_message1_idx` (`messages-id` ASC, `conversation-id` ASC, `sender` ASC) VISIBLE,
  PRIMARY KEY (`messages-id`, `conversation-id`),
  CONSTRAINT `fk_updates_message1`
    FOREIGN KEY (`messages-id` , `conversation-id` , `sender`)
    REFERENCES `mamito`.`message` (`id-messages` , `conversation-id` , `sender`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `mamito` ;

-- -----------------------------------------------------
-- procedure GetConversations
-- -----------------------------------------------------

DELIMITER $$
USE `mamito`$$
CREATE PROCEDURE `GetConversations`(IN username VARCHAR(45))
BEGIN
    SELECT *
    FROM `Conversation`
    WHERE `User-1` = username OR `User-2` = username
    ORDER BY `created-at` DESC;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetUserByPhone
-- -----------------------------------------------------

DELIMITER $$
USE `mamito`$$
CREATE PROCEDURE `GetUserByPhone`(IN phoneNumber DECIMAL(12,0))
BEGIN
	SELECT *
    FROM User
    WHERE phone = phoneNumber;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetUserByUsername
-- -----------------------------------------------------

DELIMITER $$
USE `mamito`$$
CREATE PROCEDURE `GetUserByUsername`(
	IN p_user VARCHAR(45)
)
BEGIN
    DECLARE v_user VARCHAR(45);
    DECLARE v_password VARCHAR(60);

    SELECT `username`, `password`
    INTO v_user, v_password
    FROM User
    WHERE username = p_user;
    
    IF v_user = NULL THEN
		SELECT 1015 AS status;
	ELSE
		SELECT v_user AS username, v_password AS password;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertUser
-- -----------------------------------------------------

DELIMITER $$
USE `mamito`$$
CREATE PROCEDURE InsertUser(
    IN p_username VARCHAR(45), IN p_gender ENUM('M', 'F'), IN p_birthdate DATETIME, IN p_phone BIGINT,
    IN p_password VARCHAR(60), IN p_bio VARCHAR(200), IN p_religion INT, IN p_changeOneSelf INT,
    IN p_latitude DOUBLE, IN p_longitude DOUBLE
)
BEGIN
    DECLARE user_count INT;
    DECLARE phone_count INT;

    SELECT COUNT(*) INTO user_count 
    FROM `mamito`.`user` 
    WHERE `username` = p_username;

    IF user_count = 0 THEN
		    
		SELECT COUNT(*) INTO phone_count
		FROM `mamito`.`user`
		WHERE `phone` = p_phone;
        
        IF phone_count = 0 THEN
			INSERT INTO `mamito`.`user` (
				`username`,	`gender`, `birthdate`, `phone`,
				`password`,	`bio`, `religion`,	`changeOneSelf`,
				`latitude`,	`longitude`
			) VALUES (
				p_username,	p_gender, p_birthdate, p_phone,
				p_password,	p_bio, p_religion,	p_changeOneSelf,
				p_latitude,	p_longitude
			);
			SELECT p_username AS username;
		ELSE
			SELECT 1012 AS status;
		END IF;
    ELSE
        SELECT 1011 AS status;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertConversation
-- -----------------------------------------------------

DELIMITER $$
USE `mamito`$$
CREATE PROCEDURE InsertConversation(
    IN p_user1 VARCHAR(45),
    IN p_user2 VARCHAR(45)
)
BEGIN
    DECLARE user1_count INT;
    DECLARE user2_count INT;
    
    SELECT COUNT(*) INTO user1_count
    FROM `conversation`
    WHERE `user-1` = p_user1 AND `user-2` = p_user2;

    SELECT COUNT(*) INTO user2_count
    FROM `conversation`
    WHERE `user-1` = p_user2 AND `user-2` = p_user1;

    IF user1_count = 0 AND user2_count = 0 THEN
        INSERT INTO `conversation` (`user-1`, `user-2`) VALUES (p_user1, p_user2);
        SELECT LAST_INSERT_ID() AS conversationId;
    ELSE
        SELECT 1021 AS status;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure DeleteConversation
-- -----------------------------------------------------

DELIMITER $$
USE `mamito`$$
CREATE PROCEDURE `DeleteConversation`(
    IN user1 VARCHAR(45),
    IN user2 VARCHAR(45)
)
BEGIN
	DECLARE v_conversationId INT;
    
    SELECT `conversation-id` INTO v_conversationId
	FROM `mamito`.`conversation`
	WHERE (`User-1` = user1 AND `User-2` = user2) OR (`User-1` = user2 AND `User-2` = user1);

	IF v_conversationId IS NOT NULL THEN
		DELETE FROM `mamito`.`conversation`
		WHERE (`User-1` = user1 AND `User-2` = user2) OR (`User-1` = user2 AND `User-2` = user1);
		SELECT 1025 AS status;
	ELSE 
		SELECT 1024 as status;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertMessage
-- -----------------------------------------------------

DELIMITER $$
USE `mamito`$$
CREATE PROCEDURE InsertMessage(
    IN p_conversation_id INT,
    IN p_sender VARCHAR(45),
    IN p_message VARCHAR(999)
)
BEGIN
    DECLARE participant_count INT;

    SELECT COUNT(*)
    INTO participant_count
    FROM `conversation`
    WHERE `conversation-id` = p_conversation_id
      AND (`user-1` = p_sender OR `user-2` = p_sender);

    IF participant_count > 0 THEN
        INSERT INTO `message` (`conversation-id`, `sender`, `message`)
        VALUES (p_conversation_id, p_sender, p_message);

        SELECT LAST_INSERT_ID() AS messageId;
    ELSE
		SELECT 7004 AS status;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure EditMessageText
-- -----------------------------------------------------

DELIMITER $$
USE `mamito`$$
CREATE PROCEDURE EditMessageText(
    IN p_conversation_id INT,
    IN p_message_id INT,
    IN p_sender VARCHAR(45),
    IN p_new_text VARCHAR(999)
)
BEGIN
    DECLARE v_sender VARCHAR(45);

    SELECT `sender` INTO v_sender
    FROM `mamito`.`message`
    WHERE `id-Messages` = p_message_id AND `conversation-id` = p_conversation_id;

    IF v_sender = p_sender THEN
        UPDATE `mamito`.`message`
        SET `message` = p_new_text, `updated-at` = CURRENT_TIMESTAMP
        WHERE `id-Messages` = p_message_id AND `conversation-id` = p_conversation_id;

		SELECT p_new_text AS updatedMessage;
        
    ELSE
        SELECT 7005 AS status;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetConversationId
-- -----------------------------------------------------

DELIMITER $$
USE `mamito`$$
CREATE PROCEDURE `GetConversationId` (IN user1 VARCHAR(45), IN user2 VARCHAR(45))
BEGIN
    SELECT `conversation-id`
	FROM `mamito`.`Conversation`
    WHERE `user-1` = user1 && `user-2` = user2;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure DeleteMessage
-- -----------------------------------------------------

DELIMITER $$
USE `mamito`$$
CREATE PROCEDURE DeleteMessage(
    IN p_conversation_id INT,
    IN p_message_id INT,
    IN p_sender VARCHAR(45)
)
BEGIN
    DECLARE v_sender VARCHAR(45);

    SELECT `sender` INTO v_sender
    FROM `mamito`.`message`
    WHERE `conversation-id` = p_conversation_id AND `id-Messages` = p_message_id;

    IF v_sender IS NOT NULL AND v_sender = p_sender THEN
        DELETE FROM `mamito`.`message`
        WHERE `conversation-id` = p_conversation_id AND `id-Messages` = p_message_id;

        SELECT 1007 AS status;
    ELSE
        SELECT 7003 AS status;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetLast20Messages
-- -----------------------------------------------------

DELIMITER $$
USE `mamito`$$
CREATE PROCEDURE GetLast20Messages(
    IN p_conversation_id INT,
    IN p_last_message_id INT
)
BEGIN
    SELECT *
    FROM mamito.message
    WHERE `conversation-id` = p_conversation_id
        AND `id-messages` < p_last_message_id
    ORDER BY `created-at` DESC
    LIMIT 20;
END$$

DELIMITER ;
USE `mamito`;

DELIMITER $$
USE `mamito`$$
CREATE TRIGGER after_message_insert
AFTER INSERT ON `mamito`.`message`
FOR EACH ROW
BEGIN
    INSERT INTO `mamito`.`updates` (`messages-id`, `conversation-id`, `sender`, `typeOfUpdate`)
    VALUES (NEW.`id-messages`, NEW.`conversation-id`, NEW.`sender`, 'new');
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
