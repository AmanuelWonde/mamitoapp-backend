-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mamitogw_mamito
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mamitogw_mamito` ;

-- -----------------------------------------------------
-- Schema mamitogw_mamito
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mamitogw_mamito` DEFAULT CHARACTER SET utf8mb3 ;
USE `mamitogw_mamito` ;

-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`admin`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`admin` (
  `id-admin` INT NOT NULL AUTO_INCREMENT,
  `creataed-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id-admin`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`window`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`window` (
  `id-Window` INT NOT NULL AUTO_INCREMENT,
  `views` INT NOT NULL DEFAULT '0',
  `post-date` DATETIME NULL DEFAULT NULL,
  `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id-Window`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`question`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`question` (
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
    REFERENCES `mamitogw_mamito`.`window` (`id-Window`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`choice`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`choice` (
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
    REFERENCES `mamitogw_mamito`.`question` (`id-Question` , `Window-id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`user` (
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
-- Table `mamitogw_mamito`.`answered-questoins`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`answered-questoins` (
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
    REFERENCES `mamitogw_mamito`.`choice` (`id-Choice` , `Question-id` , `Window-id`),
  CONSTRAINT `fk_answered-questoins_user1`
    FOREIGN KEY (`user-id`)
    REFERENCES `mamitogw_mamito`.`user` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`conversation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`conversation` (
  `user-1` VARCHAR(45) NOT NULL,
  `user-2` VARCHAR(45) NOT NULL,
  `conversation-id` INT NOT NULL AUTO_INCREMENT,
  `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`conversation-id`),
  INDEX `index-user-1-2` (`user-1` ASC, `user-2` ASC) VISIBLE,
  INDEX `index-user-2-1` (`user-2` ASC, `user-1` ASC) VISIBLE,
  CONSTRAINT `fk_conversation_user1`
    FOREIGN KEY (`user-1`)
    REFERENCES `mamitogw_mamito`.`user` (`username`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_conversation_user2`
    FOREIGN KEY (`user-2`)
    REFERENCES `mamitogw_mamito`.`user` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`custom-questions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`custom-questions` (
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
    REFERENCES `mamitogw_mamito`.`user` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`message`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`message` (
  `conversation-id` INT NOT NULL,
  `id-messages` INT NOT NULL,
  `sender` VARCHAR(45) NOT NULL,
  `message` VARCHAR(999) NOT NULL,
  `message-received` TINYINT NOT NULL DEFAULT 0,
  `marked-as-read` TINYINT NOT NULL DEFAULT 0,
  `created-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`conversation-id`, `id-messages`),
  INDEX `fk_message_user1_idx` (`sender` ASC) VISIBLE,
  CONSTRAINT `fk_Message_Conversatoin_conversaton-id`
    FOREIGN KEY (`conversation-id`)
    REFERENCES `mamitogw_mamito`.`conversation` (`conversation-id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_message_user1`
    FOREIGN KEY (`sender`)
    REFERENCES `mamitogw_mamito`.`user` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3
ROW_FORMAT = COMPACT;


-- -----------------------------------------------------
-- Table `mamitogw_mamito`.`user-devices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mamitogw_mamito`.`user-devices` (
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
    REFERENCES `mamitogw_mamito`.`user` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

USE `mamitogw_mamito` ;

-- -----------------------------------------------------
-- procedure GetConversations
-- -----------------------------------------------------

DELIMITER $$
USE `mamitogw_mamito`$$
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
USE `mamitogw_mamito`$$
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
USE `mamitogw_mamito`$$
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
USE `mamitogw_mamito`$$
CREATE PROCEDURE InsertUser(
    IN p_username VARCHAR(45), IN p_gender ENUM('M', 'F'), IN p_birthdate DATETIME, IN p_phone BIGINT,
    IN p_password VARCHAR(60), IN p_bio VARCHAR(200), IN p_religion INT, IN p_changeOneSelf INT,
    IN p_latitude DOUBLE, IN p_longitude DOUBLE
)
BEGIN
    DECLARE user_count INT;
    DECLARE phone_count INT;

    SELECT COUNT(*) INTO user_count 
    FROM `mamitogw_mamito`.`user` 
    WHERE `username` = p_username;

    IF user_count = 0 THEN
		    
		SELECT COUNT(*) INTO phone_count
		FROM `mamitogw_mamito`.`user`
		WHERE `phone` = p_phone;
        
        IF phone_count = 0 THEN
			INSERT INTO `mamitogw_mamito`.`user` (
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
USE `mamitogw_mamito`$$
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
USE `mamitogw_mamito`$$
CREATE PROCEDURE `DeleteConversation`(
    IN user1 VARCHAR(45),
    IN user2 VARCHAR(45)
)
BEGIN
	DECLARE v_conversationId INT;
    
    SELECT `conversation-id` INTO v_conversationId
	FROM `mamitogw_mamito`.`conversation`
	WHERE (`User-1` = user1 AND `User-2` = user2) OR (`User-1` = user2 AND `User-2` = user1);

	IF v_conversationId IS NOT NULL THEN
		DELETE FROM `mamitogw_mamito`.`conversation`
		WHERE (`User-1` = user1 AND `User-2` = user2) OR (`User-1` = user2 AND `User-2` = user1);
		SELECT 1025 AS status;
	ELSE 
		SELECT 1024 as status;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertNewMessage
-- -----------------------------------------------------

DELIMITER $$
USE `mamitogw_mamito`$$
CREATE PROCEDURE `InsertNewMessage`(
    IN p_conversation_id INT,
    IN p_sender VARCHAR(45),
    IN p_message VARCHAR(999)
)
BEGIN
    DECLARE last_message_id INT;

    -- Get the last message ID for the given conversation
    SELECT MAX(`id-messages`) INTO last_message_id
    FROM `message`
    WHERE `conversation-id` = p_conversation_id;

    -- Increment the last message ID
    IF last_message_id IS NULL THEN
		SET last_message_id = 1;
	ELSE 
		SET last_message_id = last_message_id + 1;
	END IF;

    -- Insert the new message
    INSERT INTO `message` (`conversation-id`, `id-messages`, `sender`, `message`)
    VALUES (p_conversation_id, last_message_id, p_sender, p_message);

    -- Check if the insertion was successful
    IF ROW_COUNT() > 0 THEN
        -- Return the inserted row
        SELECT *
        FROM `message`
        WHERE `conversation-id` = p_conversation_id AND `id-messages` = last_message_id;
    ELSE
        -- Return an empty result set to indicate failure
        SELECT NULL AS 'Empty result set. Insertion failed.';
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure EditMessageText
-- -----------------------------------------------------

DELIMITER $$
USE `mamitogw_mamito`$$
CREATE PROCEDURE EditMessageText(
    IN p_conversation_id INT,
    IN p_message_id INT,
    IN p_sender VARCHAR(45),
    IN p_new_text VARCHAR(999)
)
BEGIN
    DECLARE v_sender VARCHAR(45);

    SELECT `sender` INTO v_sender
    FROM `mamitogw_mamito`.`message`
    WHERE `id-Messages` = p_message_id AND `conversation-id` = p_conversation_id;

    IF v_sender = p_sender THEN
        UPDATE `mamitogw_mamito`.`message`
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
USE `mamitogw_mamito`$$
CREATE PROCEDURE `GetConversationId` (IN user1 VARCHAR(45), IN user2 VARCHAR(45))
BEGIN
    SELECT `conversation-id`
	FROM `mamitogw_mamito`.`Conversation`
    WHERE `user-1` = user1 && `user-2` = user2;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure DeleteMessage
-- -----------------------------------------------------

DELIMITER $$
USE `mamitogw_mamito`$$
CREATE PROCEDURE DeleteMessage(
    IN p_conversation_id INT,
    IN p_message_id INT,
    IN p_sender VARCHAR(45)
)
BEGIN
    DECLARE v_sender VARCHAR(45);

    SELECT `sender` INTO v_sender
    FROM `mamitogw_mamito`.`message`
    WHERE `conversation-id` = p_conversation_id AND `id-Messages` = p_message_id;

    IF v_sender IS NOT NULL AND v_sender = p_sender THEN
        DELETE FROM `mamitogw_mamito`.`message`
        WHERE `conversation-id` = p_conversation_id AND `id-Messages` = p_message_id;

        SELECT 1203 AS status;
    ELSE
        SELECT 7003 AS status;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetLast20Messages
-- -----------------------------------------------------

DELIMITER $$
USE `mamitogw_mamito`$$
CREATE PROCEDURE GetLast20Messages(
    IN p_conversation_id INT,
    IN p_last_message_id INT
)
BEGIN
    SELECT *
    FROM `mamitogw_mamito`.`message`
    WHERE `conversation-id` = p_conversation_id
        AND `id-messages` < p_last_message_id
    ORDER BY `created-at` DESC
    LIMIT 20;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetNewMessages
-- -----------------------------------------------------

DELIMITER $$
USE `mamitogw_mamito`$$
CREATE DEFINER=`AbelMaireg`@`localhost` PROCEDURE `GetNewMessages`(
    IN p_username VARCHAR(45)
)
BEGIN
	DROP TABLE IF EXISTS `mamitogw_mamito`.`temp-message`;
	CREATE TABLE `mamitogw_mamito`.`temp-message` (
	  `conversation-id` INT,
	  `id-messages` INT,
	  `sender` VARCHAR(45),
	  `message` VARCHAR(999),
	  `message-received` TINYINT,
	  `marked-as-read` TINYINT,
	  `created-at` TIMESTAMP,
	  `updated-at` TIMESTAMP,
	  PRIMARY KEY (`conversation-id`, `id-messages`)
	)
	ENGINE = InnoDB;
    
	INSERT INTO `temp-message` (
		`conversation-id`,
		`id-messages`,
		`sender`,
		`message`,
        `message-received`,
		`marked-as-read`,
		`created-at`,
		`updated-at`
	)
	SELECT
		`message`.`conversation-id`,
		`message`.`id-messages`,
		`message`.`sender`,
		`message`.`message`,
        `message`.`message-received`,
		`message`.`marked-as-read`,
		`message`.`created-at`,
		`message`.`updated-at`
	FROM
		`mamitogw_mamito`.`message`
	JOIN
		`conversation` ON `message`.`conversation-id` = `conversation`.`conversation-id`
	WHERE
		`message`.`sender` != p_username AND `message`.`message-received` = 0 AND (`conversation`.`user-1` = p_username OR `conversation`.`user-2` = p_username);
        
	UPDATE `mamitogw_mamito`.`message`
	SET `message-received` = 1
	WHERE
	  `message-received` = 0
	  AND `sender` != p_username
	  AND EXISTS (
		SELECT 1
		FROM `temp-message`
		WHERE
		  `temp-message`.`conversation-id` = `message`.`conversation-id` AND `temp-message`.`id-messages` = `message`.`id-messages`
	  );
      
	SELECT * FROM mamitogw_mamito.`temp-message`;
    
    DROP TABLE IF EXISTS `mamitogw_mamito`.`temp-message`;
END$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
