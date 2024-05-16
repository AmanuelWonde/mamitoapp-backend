-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 16, 2024 at 09:56 AM
-- Server version: 8.0.36-cll-lve
-- PHP Version: 8.1.28

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

CREATE PROCEDURE `CurrentWindowQuestions` (IN `windowId` INT)   BEGIN
    SELECT q.question AS question, q.id AS id, q.question_value AS `value`,
        JSON_ARRAYAGG(JSON_OBJECT('id', c.id, 'choice', c.choice, 'image', c.image)) AS choices
    FROM questions q
    LEFT JOIN choices c ON q.id = c.questions_id
    WHERE q.windows_id = windowId
    GROUP BY q.id;
END$$

CREATE PROCEDURE `DeleteConversation` (IN `_conversation_id` INT, IN `_username` VARCHAR(45))   BEGIN
    DECLARE _user1 VARCHAR(45);
    DECLARE _user2 VARCHAR(45);
	DECLARE _status INT;
    
    SELECT `user-1`, `user-2` INTO _user1, _user2
    FROM `conversation`
    WHERE `conversation-id` = _conversation_id;

    IF _user1 IS NULL THEN
        SET _status = 1024;
        SELECT _status as status;
    ELSE
        IF _user1 = _username OR _user2 = _username THEN
            DELETE FROM `conversation`
            WHERE `conversation-id` = _conversation_id;

            SET _status = 0;
			SELECT _status as status;
        ELSE
            SET _status = 1024;
			SELECT _status as status;
        END IF;
    END IF;

    IF _status = 0 THEN
        SELECT 
            _conversation_id AS conversationId,
            _user1 AS participant_1,
            _user2 AS participant_2,
            1024 AS status;
    END IF;
END$$

CREATE PROCEDURE `DeleteMessage` (IN `_conversationId` INT, IN `_messageId` INT, IN `_sender` VARCHAR(45))   BEGIN
    DECLARE receiver VARCHAR(45);
    DECLARE status_code INT DEFAULT 0;

    -- Check if the sender of the message is the same as the _sender parameter
    IF EXISTS (
        SELECT 1 
        FROM `mamitogw_mamito`.`message` m 
        JOIN `mamitogw_mamito`.`conversation` c ON m.`conversation-id` = c.`conversation-id`
        WHERE m.`conversation-id` = _conversationId 
        AND m.`id-messages` = _messageId
        AND m.`sender` = _sender
    ) THEN
        -- Get the receiver's username
        SELECT 
            CASE
                WHEN (SELECT `user-1` FROM `mamitogw_mamito`.`conversation` WHERE `conversation-id` = _conversationId) = _sender THEN
                    `user-2`
                ELSE
                    `user-1`
            END INTO receiver
        FROM `mamitogw_mamito`.`conversation` WHERE `conversation-id` = _conversationId;

        -- Delete the message
        DELETE FROM `mamitogw_mamito`.`message`
        WHERE `conversation-id` = _conversationId AND `id-messages` = _messageId;

        -- Check if the delete was successful
        IF ROW_COUNT() > 0 THEN
            -- Set status_code to 1203 indicating successful deletion
            SET status_code := 1203;
        ELSE
            -- Set status_code to 1103 indicating failure to delete
            SET status_code := 1103;
        END IF;
    ELSE
        -- Set status_code to 1103 indicating failure to delete
        SET status_code := 1103;
    END IF;

    -- Return conversation id, message id, status code, and receiver username
    SELECT _conversationId AS 'conversation_id', _messageId AS 'message_id', status_code AS 'status', receiver AS 'receiver';
END$$

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

CREATE PROCEDURE `DeleteSampleImage` (IN `image_id` INT)   BEGIN
DELETE FROM `sample-verification-images`
WHERE id = image_id;
END$$

CREATE PROCEDURE `deleteWindow` (IN `windowId` INT)   BEGIN
DELETE FROM windows
WHERE id = windowId;
END$$

CREATE PROCEDURE `EditMessageText` (IN `_conversationId` INT, IN `_messageId` INT, IN `_sender` VARCHAR(45), IN `new_message` VARCHAR(999))   BEGIN
    DECLARE receiver VARCHAR(45);

    -- Check if the sender of the message is the same as the _sender parameter
    IF EXISTS (
        SELECT 1 
        FROM `mamitogw_mamito`.`message` m 
        JOIN `mamitogw_mamito`.`conversation` c ON m.`conversation-id` = c.`conversation-id`
        WHERE m.`conversation-id` = _conversationId 
        AND m.`id-messages` = _messageId
        AND m.`sender` = _sender
    ) THEN
        -- Get the receiver's username
        SELECT 
            CASE
                WHEN (SELECT `user-1` FROM `mamitogw_mamito`.`conversation` WHERE `conversation-id` = _conversationId) = _sender THEN
                    `user-2`
                ELSE
                    `user-1`
            END INTO receiver
        FROM `mamitogw_mamito`.`conversation` WHERE `conversation-id` = _conversationId;

        -- Update the message text
        UPDATE `mamitogw_mamito`.`message` 
        SET `message` = new_message,
            `updated-at` = CURRENT_TIMESTAMP
        WHERE `conversation-id` = _conversationId AND `id-messages` = _messageId;

        -- Check if the update was successful
        IF ROW_COUNT() > 0 THEN
            -- Return conversation id, message id, receiver, and new message
            SELECT _conversationId AS 'conversationId', _messageId AS 'messageId', receiver AS 'receiver', new_message AS 'newMessage';
        ELSE
            -- Return error code if the message could not be updated
            SELECT 1202 AS status;
        END IF;
    ELSE
        -- Return error code if the sender of the message is not the same as _sender parameter
        SELECT 1102 AS status;
    END IF;
END$$

CREATE PROCEDURE `FindMatches` (IN `windowId` INT)   BEGIN
SELECT 
`user`.`username`,
`user`.`bio`,
`user`.`birthdate`,
`user`.`gender`,
`user`.longitude,
`user`.`latitude`,
`user`.`verified`,
`user`.`religion`,
(SELECT JSON_ARRAYAGG(p.image)
FROM (SELECT DISTINCT `image` FROM `profile-images` WHERE `user_username` = `user`.`username`) AS p) AS `profile_images`,
        (SELECT JSON_ARRAYAGG(JSON_OBJECT('questionId', a.questions_id,  'question_value', q.question_value, 'choiceId', a.choice_id))
          FROM (
            SELECT DISTINCT answers.questions_id, answers.choice_id, questions.question_value
            FROM answers
            JOIN questions ON questions.id = answers.questions_id
            WHERE answers.window_id = windowId AND answers.user_username = `user`.username
          ) AS a
          JOIN questions AS q ON q.id = a.questions_id
        ) AS `answers`
    FROM answers
    JOIN `user` ON `user`.username = answers.user_username
    LEFT JOIN `profile-images` ON `profile-images`.`user_username` = answers.user_username
    JOIN questions ON questions.id = answers.questions_id
    WHERE answers.window_id = windowId
    GROUP BY `user`.username;
END$$

CREATE PROCEDURE `GetConversations` (IN `_username` VARCHAR(45))   BEGIN
    -- Select conversation details along with the details of the other participant, the last message, and its content in each conversation
    SELECT 
        c.`conversation-id`,
        c.`user-1`,
        c.`user-2`,
        c.`status`,
        (
            SELECT COUNT(*)
            FROM `mamitogw_mamito`.`message`
            WHERE `conversation-id` = c.`conversation-id`
            AND `sender` != _username
            AND `marked-as-read` = 0
        ) AS unreadCounts,
        (
            SELECT `id-messages`
            FROM `mamitogw_mamito`.`message`
            WHERE `conversation-id` = c.`conversation-id`
            ORDER BY `created-at` DESC
            LIMIT 1
        ) AS last_message_id,
        (
            SELECT `message`
            FROM `mamitogw_mamito`.`message`
            WHERE `conversation-id` = c.`conversation-id`
            ORDER BY `created-at` DESC
            LIMIT 1
        ) AS last_message_content,
        u.`username`,
        u.`gender`,
        u.`birthdate`,
        u.`name`,
        u.`phone`,
        u.`bio`,
        u.`religion`,
        u.`changeOneSelf`
    FROM 
        `mamitogw_mamito`.`conversation` c
    INNER JOIN
        `mamitogw_mamito`.`user` u ON ((c.`user-1` = u.`username` AND c.`user-2` = _username) OR (c.`user-1` = _username AND c.`user-2` = u.`username`))
    WHERE 
        c.`user-1` = _username OR c.`user-2` = _username;
END$$

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
WHERE `start_at` > (SELECT `end_at` 
FROM `windows` WHERE id = p_current_window_id)
ORDER BY `start_at`
LIMIT 1;

SELECT p_current_window_id AS CurrentWindowID,   DATE_FORMAT(p_next_window_start_at, 
'%Y-%m-%d %H:%i:%s') AS NextWindowStartTime;
END IF;
END$$

CREATE PROCEDURE `GetDeviceId` (IN `_username` VARCHAR(45))   BEGIN
	SELECT `deviceId`
    FROM `device-id`
    WHERE `username` = _username;
END$$

CREATE PROCEDURE `GetLast20Messages` (IN `_conversationId` INT, IN `_messageId` INT)   BEGIN
    DECLARE status_code INT DEFAULT 1204;

	IF _messageId = 0 THEN
		SELECT
			`conversation-id`,
			`id-messages`,
			`sender`,
			`message`,
			`created-at`,
			`updated-at`
		FROM
			`mamitogw_mamito`.`message`
		WHERE 
			`conversation-id` = _conversationId
		ORDER BY 
			`id-messages` DESC
		LIMIT 20;
    -- Retrieve the last 20 messages sent before the specified message
    ELSE
		SELECT 
			`conversation-id`, 
			`id-messages`, 
			`sender`, 
			`message`, 
			`created-at`, 
			`updated-at`
		FROM 
			`mamitogw_mamito`.`message`
		WHERE 
			`conversation-id` = _conversationId AND `id-messages` < _messageId
		ORDER BY 
			`id-messages` DESC
		LIMIT 20;
	END IF;
END$$

CREATE PROCEDURE `getProfileData` (IN `_username` VARCHAR(45))   BEGIN

SELECT
    t.username,
    t.employmentStatus,
    t.rangeOfSearch,
    t.rightPath,
    JSON_OBJECTAGG(k.type, k.value) AS kindOfPerson
FROM
    profiledata t
JOIN
    kindOfPerson k ON t.username = k.username
WHERE
    t.username = _username
GROUP BY
    t.username,
    t.employmentStatus,
    t.rangeOfSearch,
    t.rightPath;

END$$

CREATE PROCEDURE `GetRecoveryQuestions` (IN `_username` VARCHAR(45))   BEGIN
    DECLARE _count INT;
    DECLARE _status INT;

    -- Check if recovery questions are answered by the user
    SELECT 
        COUNT(*) INTO _count
    FROM 
        `pd-rcv-ans`
    WHERE 
        `user` = _username;

    IF _count = 0 THEN
        SELECT 1081 as status; -- No questions found status code
    ELSE
        SET _status = 1080; -- Questions found status code
    END IF;
    
    -- Return the list of question IDs if available
    IF _status = 1080 THEN
        SELECT `question-id`
        FROM 
            `pd-rcv-ans`
        WHERE 
            `user` = _username;
    END IF;
END$$

CREATE PROCEDURE `GetSampleImages` (IN `inputGender` VARCHAR(50))   BEGIN
    SELECT * FROM `sample-verification-images` 
    WHERE gender = inputGender;
END$$

CREATE PROCEDURE `GetUserByUsername` (IN `_username` VARCHAR(45))   BEGIN
    -- Declare variables to store user information
    DECLARE v_username VARCHAR(45);
    DECLARE v_name VARCHAR(45);
    DECLARE v_gender ENUM('M', 'F');
    DECLARE v_birthdate DATETIME;
    DECLARE v_phone BIGINT;
    DECLARE v_password VARCHAR(60);
    DECLARE v_bio VARCHAR(45);
    DECLARE v_religion INT;
    DECLARE v_changeOneSelf INT;
    DECLARE v_latitude DOUBLE;
    DECLARE v_longitude DOUBLE;

    -- Initialize status variable
    DECLARE _status INT;

    -- Retrieve user information
    SELECT `username`, `name`, `gender`, `birthdate`, `phone`, `password`, `bio`, `religion`, `changeOneSelf`, `latitude`, `longitude`
    INTO v_username, v_name, v_gender, v_birthdate, v_phone, v_password, v_bio, v_religion, v_changeOneSelf, v_latitude, v_longitude
    FROM `user`
    WHERE `username` = _username;

    -- Check if user exists
    IF FOUND_ROWS() > 0 THEN
        -- Set status to success
        SET _status = 1013;
    ELSE
        -- Set status to failure
        SET _status = 1015;
    END IF;

    -- Return user information and status
    SELECT v_username AS username, v_name AS name, v_gender AS gender, v_birthdate AS birthdate, v_phone AS phone, v_password AS password, v_bio AS bio, v_religion AS religion, v_changeOneSelf AS changeOneSelf, v_latitude AS latitude, v_longitude AS longitude, _status AS status;
END$$

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

CREATE PROCEDURE `InsertChoice` (IN `questionId` INT, IN `choiceValue` VARCHAR(100), IN `image` VARCHAR(255))  DETERMINISTIC BEGIN
    INSERT INTO choices (questions_id, choice, image)
    VALUES (questionId, choiceValue, image);
END$$

CREATE PROCEDURE `InsertConversation` (IN `_user1` VARCHAR(45), IN `_user2` VARCHAR(45))   BEGIN
    DECLARE _conversation_id INT;
    DECLARE _status INT;
    
    SELECT `conversation-id` INTO _conversation_id
    FROM `conversation`
    WHERE (`user-1` = _user1 AND `user-2` = _user2)
        OR (`user-1` = _user2 AND `user-2` = _user1);

    IF _conversation_id IS NOT NULL THEN
		SET _status = 1021;
        SELECT 1021 AS status;
    ELSE
        BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                ROLLBACK;
                SET _status = 1022;
                SELECT 1022 AS status;
            END;

            START TRANSACTION;
            INSERT INTO `conversation` (`user-1`, `user-2`, `status`)
            VALUES (_user1, _user2, 'new');
            SET _conversation_id = LAST_INSERT_ID();
            COMMIT;
        END;
        
        IF _status IS NULL THEN
            SET _status = 0;
        END IF;
    END IF;

    IF _status = 0 THEN
        SELECT
            c.`conversation-id`,
            c.`user-1`,
            c.`user-2`,
            c.`created-at`,
            c.`updated-at`,
            u.username,
            u.gender,
            u.birthdate,
            u.phone,
            u.bio,
            u.religion,
            u.changeOneSelf
        FROM 
            `conversation` c
        INNER JOIN 
            `user` u ON c.`user-2` = u.username
        WHERE 
            c.`conversation-id` = _conversation_id;
    END IF;
END$$

CREATE PROCEDURE `InsertDeviceId` (IN `_username` VARCHAR(45), IN `_deviceId` VARCHAR(500))   BEGIN
	INSERT INTO `device-id` (`username`, `deviceId`)
    VALUE (_username, _deviceId)
    ON DUPLICATE KEY UPDATE `deviceId` = _deviceId;
END$$

CREATE PROCEDURE `insertKindOfPerson` (IN `_username` VARCHAR(45), IN `_key` INT, IN `_value` TINYINT)   BEGIN
	INSERT INTO `kindOfPerson`
	VALUE (_username, _key, _value)
    ON DUPLICATE KEY UPDATE
		`username` = _username,
        `type` = _key,
        `value` = _value;
END$$

CREATE PROCEDURE `InsertNewMessage` (IN `_conversationId` INT, IN `_sender` VARCHAR(45), IN `_message` VARCHAR(999))   BEGIN
    DECLARE receiver VARCHAR(45);

    -- Check if the sender is a participant of the conversation
    IF EXISTS (
        SELECT 1 
        FROM `mamitogw_mamito`.`conversation` c 
        WHERE c.`conversation-id` = _conversationId 
        AND (c.`user-1` = _sender OR c.`user-2` = _sender)
    ) THEN
        -- Get the receiver's username
        SELECT 
            CASE
                WHEN (SELECT `user-1` FROM `mamitogw_mamito`.`conversation` WHERE `conversation-id` = _conversationId) = _sender THEN
                    `user-2`
                ELSE
                    `user-1`
            END INTO receiver
        FROM `mamitogw_mamito`.`conversation` WHERE `conversation-id` = _conversationId;
        
        -- Insert the new message
        INSERT INTO `mamitogw_mamito`.`message` (`conversation-id`, `sender`, `message`)
        VALUES (_conversationId, _sender, _message);
        
        -- Return receiver's username, conversation ID, and new message
        SELECT *, (SELECT receiver) AS receiver 
        FROM `message`
        WHERE `id-messages`= last_insert_id();
    ELSE
        -- Return error code
        SELECT '1101' AS 'error_code';
    END IF;
END$$

CREATE PROCEDURE `insertProfileData` (IN `_username` VARCHAR(45), IN `_employmentStatus` INT, IN `_rangeOfSearch` DOUBLE, IN `_rightPath` INT)   BEGIN
    INSERT INTO `profiledata` (`username`, `employmentStatus`, `rangeOfSearch`, `rightPath`)
    VALUES (_username, _employmentStatus, _rangeOfSearch, _rightPath)
    ON DUPLICATE KEY UPDATE
        `employmentStatus` = _employmentStatus,
        `rangeOfSearch` = _rangeOfSearch,
        `rightPath` = _rightPath;
END$$

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

CREATE PROCEDURE `InsertUser` (IN `_username` VARCHAR(45), IN `_name` VARCHAR(45), IN `_gender` ENUM('M','F'), IN `_birthdate` DATETIME, IN `_phone` BIGINT, IN `_password` VARCHAR(60), IN `_bio` VARCHAR(45), IN `_religion` INT, IN `_changeOneSelf` INT, IN `_latitude` DOUBLE, IN `_longitude` DOUBLE)   BEGIN
    DECLARE username_count INT;
    DECLARE phone_count INT;

    -- Check if username already exists
    SELECT COUNT(*) INTO username_count FROM `user` WHERE `username` = _username;
    
    -- Check if phone already exists
    SELECT COUNT(*) INTO phone_count FROM `user` WHERE `phone` = _phone;

    -- If username exists, return 1011
    IF username_count > 0 THEN
        SELECT 1011 AS status;
    -- If phone exists, return 1012
    ELSEIF phone_count > 0 THEN
        SELECT 1012 AS status;
    ELSE
        -- Insert new user
        INSERT INTO `user` (`username`, `name`, `gender`, `birthdate`, `phone`, `password`, `bio`, `religion`, `changeOneSelf`, `latitude`, `longitude`)
        VALUES (_username, _name, _gender, _birthdate, _phone, _password, _bio, _religion, _changeOneSelf, _latitude, _longitude);

        -- Return status 1010 for successful insertion
        SELECT 1010 AS status;
    END IF;
END$$

CREATE PROCEDURE `InsertUserAnswers` (IN `windowId` INT, IN `userName` VARCHAR(255), IN `questionId` INT, IN `choiceId` INT, IN `mood` VARCHAR(50))   BEGIN
    INSERT INTO answers (window_id, user_username, questions_id, choice_id, mood)
    VALUES (windowId, userName, questionId, choiceId, mood);
END$$

CREATE PROCEDURE `InsertWindow` (IN `name` VARCHAR(50), IN `startDate` DATETIME, IN `endDate` DATETIME, OUT `insertedId` INT)   BEGIN
    INSERT INTO windows (name, start_at, end_at)
    VALUES (name, startDate, endDate);
      SET insertedId = LAST_INSERT_ID();
END$$

CREATE PROCEDURE `ReadMarker` (IN `_conversationId` INT, IN `_username` VARCHAR(45))   BEGIN
    DECLARE other_user VARCHAR(45);
    
    -- Get the username of the other participant in the conversation
    SELECT 
        CASE
            WHEN `user-1` = _username THEN `user-2`
            ELSE `user-1`
        END INTO other_user
    FROM 
        `mamitogw_mamito`.`conversation`
    WHERE 
        `conversation-id` = _conversationId;

    -- Set 'marked-as-read' of all messages sent by the other user to 1
    UPDATE 
        `mamitogw_mamito`.`message`
    SET 
        `marked-as-read` = 1
    WHERE 
        `conversation-id` = _conversationId
        AND `sender` = other_user;

    -- Return conversation ID, username of the other participant, and status (1207)
    SELECT 
        _conversationId AS 'conversationId', 
        other_user AS 'receiver', 
        1207 AS 'status';
END$$

CREATE PROCEDURE `SaveRecoveryAnswers` (IN `_username` VARCHAR(45), IN `_q1` INT, IN `_q2` INT, IN `_q3` INT, IN `_ans1` VARCHAR(200), IN `_ans2` VARCHAR(200), IN `_ans3` VARCHAR(200))   BEGIN
    INSERT INTO `pd-rcv-ans` (`user`, `question-id`, `answer`) 
    VALUES 
        (_username, _q1, _ans1),
        (_username, _q2, _ans2),
        (_username, _q3, _ans3)
    ON DUPLICATE KEY UPDATE
        `answer` = VALUES(`answer`);
        
	SELECT 1050 AS status;
END$$

CREATE PROCEDURE `UpdateConversationStatus` (IN `_id` INT, IN `_convStatus` VARCHAR(10))   BEGIN
    
    IF _convStatus = 'accept' THEN
        UPDATE `conversation`
        SET `status` = 'open'
        WHERE `conversation-id` = _id;
        
        SELECT `conversation-id` AS conversationId, `user-1`, `user-2`, 1040 AS status
        FROM `conversation`
        WHERE `conversation-id` = _id;
        
    ELSEIF _convStatus = 'reject' THEN
        UPDATE `conversation`
        SET `status` = _convStatus
        WHERE `conversation-id` = _id;
        
        SELECT `conversation-id` AS conversationId, `user-1`, `user-2`, 1041 AS status
        FROM `conversation`
        WHERE `conversation-id` = _id;
        
    ELSEIF _convStatus = 'remove' THEN
        DELETE FROM `conversation`
        WHERE `conversation-id` = _id;
        
        SELECT _id AS conversationId, 1042 AS status;
        
    ELSE 
        SELECT 1044 AS status;
    END IF;
    
END$$

CREATE PROCEDURE `UpdatePassword` (IN `_username` VARCHAR(45), IN `_newPassword` VARCHAR(60))   BEGIN
	UPDATE `user`
    SET `password` = _newPassword;
    
    SELECT 1060 AS status;
END$$

CREATE PROCEDURE `UpdateProfileQuestionsAnswer` (IN `userName` VARCHAR(45), IN `questionId` INT, IN `choiceId` INT)   BEGIN
UPDATE `profile-question-answers` 
SET `profile-question-choices_id` = choiceId
WHERE `profile-questions_id` = questionId AND user_username = userName;
END$$

CREATE PROCEDURE `UpdateUser` (IN `_username` VARCHAR(45), IN `_name` VARCHAR(45), IN `_gender` ENUM('M','F'), IN `_birthdate` DATETIME, IN `_phone` BIGINT, IN `_bio` VARCHAR(45), IN `_religion` INT, IN `_changeOneSelf` INT, IN `_latitude` DOUBLE, IN `_longitude` DOUBLE)   BEGIN
	DECLARE _status INT;
	
    -- Update the user information
    UPDATE `user`
    SET 
        `name` = _name,
        `gender` = _gender,
        `birthdate` = _birthdate,
        `phone` = _phone,
        `bio` = _bio,
        `religion` = _religion,
        `changeOneSelf` = _changeOneSelf,
        `latitude` = _latitude,
        `longitude` = _longitude
    WHERE 
        `username` = _username;

    -- Check if the update was successful
    IF ROW_COUNT() > 0 THEN
        SET _status = 0; -- Success status code
    ELSE
        SET _status = 1031; -- Failure status code
    END IF;
    
        SELECT `username`, `name`, `gender`, `birthdate`, `phone`, `bio`, `religion`, `changeOneSelf`, `latitude`, `longitude`, _status as status
        FROM `user`
        WHERE `username` = _username;
END$$

CREATE PROCEDURE `updateVerified` (IN `_username` VARCHAR(45), IN `_verified` TINYINT)   BEGIN
	UPDATE `user`
    SET `verified` = _verified
    WHERE `username` = _username;
    
    IF _verified = 0 THEN
		SELECT 1033 AS status;
	ELSE 
		SELECT 1032 AS status;
	END IF;
    
END$$

CREATE PROCEDURE `UpdateWindow` (IN `windowId` INT, IN `newName` VARCHAR(200), IN `newStartAt` DATETIME, IN `newEndAt` DATETIME)   BEGIN
UPDATE windows
    SET
        name = newName,
        start_at = newStartAt,
        end_at = newEndAt
    WHERE
        id = windowId;
END$$

CREATE PROCEDURE `UserProfileData` (IN `username` VARCHAR(50))   BEGIN
SELECT  `user`.*,
JSON_ARRAYAGG(`profile-images`.`image`) AS profile_images
FROM `user`
JOIN `profile-images` ON `profile-images`.`user_username` = `user`.`username`
WHERE `user`.`username` = username  
GROUP BY  `user`.`username`;  
END$$

CREATE PROCEDURE `ValidateRecoveryAnswers` (IN `_username` VARCHAR(45), IN `_id1` INT, IN `_id2` INT, IN `_id3` INT, IN `_ans1` VARCHAR(200), IN `_ans2` VARCHAR(200), IN `_ans3` VARCHAR(200))   BEGIN
    DECLARE _count INT;
    DECLARE _status INT;

    SELECT 
        COUNT(*) INTO _count
    FROM 
        `pd-rcv-ans`
    WHERE 
        `user` = _username
        AND ((`question-id` = _id1 AND `answer` = _ans1) OR
             (`question-id` = _id2 AND `answer` = _ans2) OR
             (`question-id` = _id3 AND `answer` = _ans3));

    IF _count = 3 THEN
        SET _status = 1070;
    ELSE
        SET _status = 1071;
    END IF;
    
    SELECT _status AS status;
END$$

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
SELECT uvi.`sample-verification-images_id`  AS sampleImageId, uvi.id, uvi.image, uvi.status, uvi.user_username AS username, svi.image AS sampleImage
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
  `user_username` varchar(45) NOT NULL,
  `mood` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `answers`
--

INSERT INTO `answers` (`id`, `window_id`, `choice_id`, `created_at`, `updated_at`, `questions_id`, `user_username`, `mood`) VALUES
(1883, 2, 8, '2024-05-15 19:50:07', '2024-05-15 19:50:07', 7, 'beamlak', 'HAPPY');

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
(865, '', '2024-05-15 05:30:35', '2024-05-15 05:30:35', 449, 'questions[0][choices][0][image]-1715751032873.png'),
(866, '', '2024-05-15 05:30:35', '2024-05-15 05:30:35', 449, 'questions[0][choices][1][image]-1715751033879.png'),
(867, '', '2024-05-15 05:30:35', '2024-05-15 05:30:35', 450, 'questions[1][choices][0][image]-1715751034673.png'),
(868, '', '2024-05-15 05:30:35', '2024-05-15 05:30:35', 450, 'questions[1][choices][1][image]-1715751034855.png'),
(869, '', '2024-05-15 05:30:35', '2024-05-15 05:30:35', 451, 'questions[2][choices][0][image]-1715751034888.png'),
(870, '', '2024-05-15 05:30:35', '2024-05-15 05:30:35', 451, 'questions[2][choices][1][image]-1715751034930.png'),
(871, '', '2024-05-15 06:15:44', '2024-05-15 06:15:44', 452, 'questions[0][choices][0][image]-1715753744429.png'),
(872, '', '2024-05-15 06:15:44', '2024-05-15 06:15:44', 452, 'questions[0][choices][1][image]-1715753744492.png'),
(873, '', '2024-05-15 06:15:44', '2024-05-15 06:15:44', 453, 'questions[1][choices][0][image]-1715753744500.png'),
(874, '', '2024-05-15 06:15:44', '2024-05-15 06:15:44', 453, 'questions[1][choices][1][image]-1715753744508.png'),
(875, '', '2024-05-15 06:15:44', '2024-05-15 06:15:44', 454, 'questions[2][choices][0][image]-1715753744516.png'),
(876, '', '2024-05-15 06:15:44', '2024-05-15 06:15:44', 454, 'questions[2][choices][1][image]-1715753744522.png'),
(877, '', '2024-05-15 06:15:44', '2024-05-15 06:15:44', 455, 'questions[3][choices][0][image]-1715753744529.png'),
(878, '', '2024-05-15 06:15:44', '2024-05-15 06:15:44', 455, 'questions[3][choices][1][image]-1715753744534.png'),
(879, '', '2024-05-15 06:15:44', '2024-05-15 06:15:44', 456, 'questions[4][choices][0][image]-1715753744539.png'),
(880, '', '2024-05-15 06:15:44', '2024-05-15 06:15:44', 456, 'questions[4][choices][1][image]-1715753744545.png');

-- --------------------------------------------------------

--
-- Table structure for table `conversation`
--

CREATE TABLE `conversation` (
  `user-1` varchar(45) NOT NULL,
  `user-2` varchar(45) NOT NULL,
  `conversation-id` int NOT NULL,
  `status` enum('new','open','reject') NOT NULL DEFAULT 'new',
  `created-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `conversation`
--

INSERT INTO `conversation` (`user-1`, `user-2`, `conversation-id`, `status`, `created-at`, `updated-at`) VALUES
('amanuel', 'user0001', 25, 'new', '2024-05-12 12:17:31', '2024-05-12 12:17:31'),
('user0002', 'user0001', 26, 'open', '2024-05-12 13:16:25', '2024-05-12 13:16:25');

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
(17, 'profileImage-1709014285008.jpg', '2024-02-27 07:25:33', 'hannibal'),
(19, 'profileImage-1713082720035.jpg', '2024-05-02 02:31:22', 'amanuel'),
(20, 'profileImage-1715083802567.jpg', '2024-05-07 16:07:26', 'heruyd321'),
(21, 'profileImage-1715539703304.jpg', '2024-05-13 18:42:16', 'heruyd123'),
(22, 'profileImage-1715614982287.jpg', '2024-05-13 18:43:28', 'heruyd123');

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
('amanwondet', 'c3PpgRVCSvKJUA18gLZPIg:APA91bFXbxob-YtZ4grp00JO_JRehtbxXjkenHJgzUYH1TYqh_JuR-4mDaAco_btTDnmpbPY4BiLDA37p9wLpoVtU-GrqdAY7uD5DkFi_2olJp-MfDLx5EfAvUucqKIzAECnRVFarVRF'),
('daemon', 'camHIwqITkKL3KZySziUb7:APA91bFw0tA9yjMqDOXUoC0mGYIYeVCAVnIhuKAZ6CZZVdgDQNf7PwBRzeFMzyRCIdXv_wBzamYGYEItr5lq_XTlGzHL2sByKt-SBYzplqzVdEdb5xqqQh4uB14JeXZh3n2Ke9GCrHGe'),
('newuser2', 'cg1hcfOxTO2WUusXy83rsu:APA91bEFDzeEbrggs0WkTxRabvNU_tZzwJJon5rD0uuDXduVoII0HMGoMSI9BdiZvaGxGn2Px0hw6k_2kwLr_JAFa54CoGFxefvyvnQR7FgYXmUcNlVnO_gO3ZBQGO5Q_LFEpb8W654I'),
('trialacc123', 'cjYuHeyVTYqpqwwKvQxqAu:APA91bF_THHnLIqEkrSewCn-LU5-rNMq6t2ZrbYHoceq-jCuT83vlZZBt1_QnO5yXe6zUqaE8FOxuGvYhVMS2bMHy6gJI8sYoY1HrfTwAtF3TTv02LM3cIUygDZbf2OZiuuroHIPD5aR'),
('amanuel', 'cMJHbRfTT7e5w5m3ChWDem:APA91bE-DGj-efOFqm7qyQRgs0hDBThzOd7U8jpdR04H2ylDN1OyycWEciZ9ILtVLQ5i1ttLJzcwov-yHE2ChJfXevZ6aO3d07h_P8ByZLIPLKaxLJfkFNlGDLvn8NmDmQDa3aYVVpnz'),
('heruyd123', 'dAvdofBCTjedZ7z61DNF2K:APA91bGAcH7VXJl513Df5a9Bo_Td6rGne9TxCH6gz6rlGO0KnfqGH89l10wrVOaMCZRHaOnVguY5k5K6e3zl-TBEiXjoueZjzmsxtvQj6Pj8WUDQxMzNoiF7o6H71aVZUjVTXvR7_lMO'),
('user0001', 'dP7vXcA8S0O7JBwFYtycmF:APA91bEs2StMLOvdC4-MQ-2qLQDvXcb_Hu2lloXGs1WliIyqIM5YkhI3-zlJAzfeqcEwe6kVv3qRo6AYYPVKdtvoULP_Z18rNS-Na51dCtK-tS4-oJYAyK8TnyWLXDSgkK9Sk-IVW4HB'),
('user0002', 'dP7vXcA8S0O7JBwFYtycmF:APA91bEs2StMLOvdC4-MQ-2qLQDvXcb_Hu2lloXGs1WliIyqIM5YkhI3-zlJAzfeqcEwe6kVv3qRo6AYYPVKdtvoULP_Z18rNS-Na51dCtK-tS4-oJYAyK8TnyWLXDSgkK9Sk-IVW4HB'),
('newuser3', 'eCfHhi3WTyGaeqLX463TWy:APA91bFo1jCyb6ft-rqGJKTZHNVxyxoCPfI7rRxoxisnwkxwLH39-FFCAeJXXZ-2Znc7_ZhU21fW6I7DCogXmbIjtht6_Y-CTHOkc4-I1vi1hhaL0VwsGEFhuxj7sGTUAi38RVgIOnyE'),
('newuser10', 'eznKTTL9T42vdYGRAfZxRa:APA91bF7tz1eBE1cXEoTVa6ya0ebeAAy7OVAukh8bAZ4T93sDItoGz3C4MSiwzlj9JBFveIAVoLeE24KOwEn9jvugVkqO1NDYTYWprO08Wa8mZPvU_0DI4HX4kFn-yM0ySkKeK_ELk6T'),
('newuser20', 'eznKTTL9T42vdYGRAfZxRa:APA91bF7tz1eBE1cXEoTVa6ya0ebeAAy7OVAukh8bAZ4T93sDItoGz3C4MSiwzlj9JBFveIAVoLeE24KOwEn9jvugVkqO1NDYTYWprO08Wa8mZPvU_0DI4HX4kFn-yM0ySkKeK_ELk6T'),
('newuser30', 'eznKTTL9T42vdYGRAfZxRa:APA91bF7tz1eBE1cXEoTVa6ya0ebeAAy7OVAukh8bAZ4T93sDItoGz3C4MSiwzlj9JBFveIAVoLeE24KOwEn9jvugVkqO1NDYTYWprO08Wa8mZPvU_0DI4HX4kFn-yM0ySkKeK_ELk6T'),
('wamanuel', 'f2KA91E8RXGPeIy6HJnIKY:APA91bHWJAN11X9P16v-7iAsS-NpdEEN1AUApmbdA8cgmZypJQPIAcvkMDdzAuQxqt73SrwQe6hSaS2MCSA5JkOcz8gh9L9SQV-0WEozaHgCU1TxwxKXDZ61Q9gn2DdiiUGDbJmLbvW-'),
('wondeamanuel', 'f2KA91E8RXGPeIy6HJnIKY:APA91bHWJAN11X9P16v-7iAsS-NpdEEN1AUApmbdA8cgmZypJQPIAcvkMDdzAuQxqt73SrwQe6hSaS2MCSA5JkOcz8gh9L9SQV-0WEozaHgCU1TxwxKXDZ61Q9gn2DdiiUGDbJmLbvW-'),
('heruyd321@', 'fpMRljpnTj-zPQYMKoya3j:APA91bH1lkn-VaQCgk_R7NHSlqITWWSTkkGJIajyjl40qlEZMnRWeEC3EVpnDmSWsutaLtZZux9SPStdQaCFw6ickwf3D04jD-qSuUbtIOol2cMD6_JZ_dtrxrzGNS01SofXHML2FCX5'),
('heruyd321', 'fvhCRInYTaWe0lPZnXGqDU:APA91bFAuse5OYzqA1voKINK8HH0h3mCTGuh83qbdqXoqwTVYIXV3hQhY4CgFySV7yYd0_wMRzUlDzDqhAn8NPs6OHIWNf019kgGKfA4RY3DKxc9aKZDWqKtSZB4aVuvTVg7rIoAilNI');

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

--
-- Dumping data for table `kindOfPerson`
--

INSERT INTO `kindOfPerson` (`username`, `type`, `value`) VALUES
('heruyd123', 1, 0),
('heruyd123', 2, 0),
('heruyd123', 3, 0),
('heruyd123', 4, 1),
('heruyd123', 5, 1),
('heruyd123', 6, 0),
('heruyd321', 1, 0),
('heruyd321', 2, 0),
('heruyd321', 3, 0),
('heruyd321', 4, 0),
('heruyd321', 5, 0),
('heruyd321', 6, 0),
('heruyd321@', 1, 0),
('heruyd321@', 2, 0),
('heruyd321@', 3, 0),
('heruyd321@', 4, 1),
('heruyd321@', 5, 1),
('heruyd321@', 6, 1),
('newuser01', 1, 1),
('newuser01', 2, 0),
('newuser01', 3, 1),
('newuser01', 4, 0),
('newuser01', 5, 0),
('newuser01', 6, 0),
('trialacc123', 1, 1),
('trialacc123', 2, 1),
('trialacc123', 3, 1),
('trialacc123', 4, 0),
('trialacc123', 5, 0),
('trialacc123', 6, 0),
('user0001', 1, 1),
('user0001', 2, 1),
('user0001', 3, 0),
('user0001', 4, 0),
('user0001', 5, 0),
('user0001', 6, 0);

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `id-messages` int NOT NULL,
  `conversation-id` int NOT NULL,
  `sender` varchar(45) NOT NULL,
  `message` varchar(999) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `message-received` tinyint NOT NULL DEFAULT '0',
  `marked-as-read` tinyint NOT NULL DEFAULT '0',
  `created-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT;

--
-- Dumping data for table `message`
--

INSERT INTO `message` (`id-messages`, `conversation-id`, `sender`, `message`, `message-received`, `marked-as-read`, `created-at`, `updated-at`) VALUES
(29, 25, 'amanuel', 'this is a message from postman 3', 0, 1, '2024-05-12 12:18:11', '2024-05-12 12:18:11'),
(30, 25, 'amanuel', 'this is a message from postman 3', 0, 1, '2024-05-12 12:18:37', '2024-05-12 12:18:37'),
(31, 25, 'amanuel', 'this is a message from postman 3', 0, 1, '2024-05-12 12:18:44', '2024-05-12 12:18:44'),
(32, 25, 'amanuel', 'this is a message from postman 3', 0, 1, '2024-05-12 12:48:22', '2024-05-12 12:48:22'),
(33, 25, 'amanuel', 'this is a message from postman 3', 0, 1, '2024-05-12 12:52:11', '2024-05-12 12:52:11'),
(34, 25, 'amanuel', 'this is a message from postman 3', 0, 1, '2024-05-12 13:03:30', '2024-05-12 13:03:30'),
(35, 25, 'amanuel', 'this is a message from postman 3', 0, 1, '2024-05-12 13:05:12', '2024-05-12 13:05:12'),
(36, 26, 'user0001', '1', 0, 0, '2024-05-12 15:54:08', '2024-05-12 15:54:08'),
(37, 26, 'user0001', 'q', 0, 0, '2024-05-12 15:54:38', '2024-05-12 15:54:38');

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
(164, 'profileImage-1715539868479.jpg', 'newuser10', '2024-05-12 21:51:08', '2024-05-12 21:51:08'),
(165, 'profileImage-1715540711919.jpg', 'newuser20', '2024-05-12 22:05:11', '2024-05-12 22:05:11'),
(166, 'profileImage-1715540819986.jpg', 'trialacc123', '2024-05-12 22:07:00', '2024-05-12 22:07:00'),
(167, 'profileImage-1715541043319.jpg', 'newuser30', '2024-05-12 22:10:43', '2024-05-12 22:10:43'),
(168, 'profileImage-1715574209713.jpg', 'amanuel', '2024-05-13 07:23:29', '2024-05-13 07:23:29'),
(170, 'profileImage-1715615034407.jpg', 'heruyd123', '2024-05-13 18:43:54', '2024-05-13 18:43:54'),
(171, 'profileImage-1715619125606.jpg', 'daemon', '2024-05-13 19:52:05', '2024-05-13 19:52:05');

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
-- Table structure for table `profiledata`
--

CREATE TABLE `profiledata` (
  `username` varchar(45) NOT NULL,
  `employmentStatus` int DEFAULT NULL,
  `rangeOfSearch` double DEFAULT NULL,
  `rightPath` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `profiledata`
--

INSERT INTO `profiledata` (`username`, `employmentStatus`, `rangeOfSearch`, `rightPath`) VALUES
('heruyd123', 1, 50, 2),
('heruyd321', 1, 50, 0),
('heruyd321@', 1, 25, 2),
('newuser01', 0, 29, 1),
('trialacc123', 1, 48, 0),
('user0001', 1, 10, 0);

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
(449, '1', 10, '2024-05-15 05:30:35', '2024-05-15 05:30:35', 175),
(450, '2', 10, '2024-05-15 05:30:35', '2024-05-15 05:30:35', 175),
(451, '3', 80, '2024-05-15 05:30:35', '2024-05-15 05:30:35', 175),
(452, '1', 10, '2024-05-15 06:15:44', '2024-05-15 06:15:44', 176),
(453, '2', 10, '2024-05-15 06:15:44', '2024-05-15 06:15:44', 176),
(454, '3', 10, '2024-05-15 06:15:44', '2024-05-15 06:15:44', 176),
(455, '4', 10, '2024-05-15 06:15:44', '2024-05-15 06:15:44', 176),
(456, '5', 60, '2024-05-15 06:15:44', '2024-05-15 06:15:44', 176);

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
(79, 'image-1715528178814.jpg', 'M'),
(78, 'image-1715502960767.jpg_large', 'M'),
(71, 'image-1715502283218.jpg', 'F'),
(72, 'image-1715502331604.jpg', 'F'),
(73, 'image-1715502349501.jpg', 'F'),
(74, 'image-1715502372207.jpg', 'F'),
(75, 'image-1715502392988.jpg', 'F'),
(76, 'image-1715502413436.jpg', 'F'),
(77, 'image-1715502843083.webp', 'M'),
(80, 'image-1715528193731.jpg', 'M');

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
  `religion` int NOT NULL,
  `longitude` double NOT NULL,
  `verified` tinyint NOT NULL DEFAULT '0',
  `latitude` double NOT NULL,
  `created-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated-at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `changeOneSelf` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`username`, `name`, `gender`, `birthdate`, `phone`, `password`, `bio`, `religion`, `longitude`, `verified`, `latitude`, `created-at`, `updated-at`, `changeOneSelf`) VALUES
('amanuel', 'amanuel wonde', 'M', '2008-05-17 00:00:00', 251967292497, '$2a$10$aQhhq44y85SHHsXsJk/.XeK9Eu0kY3P7JRw4W0o7LvI9vTh6XdyI2', 'hi', 1, 38.8103321, 1, 8.8888488, '2024-05-13 04:23:04', '2024-05-13 04:23:04', '1'),
('daemon', 'ammar mohammed', 'M', '2001-01-01 00:00:00', 251941806250, '$2a$10$efc4jT702FwXgpKu/9nBhu4MqI243Od76ycXdZ0Z67Dm1bZtdkDwG', 'dream', 2, 38.8118834, 0, 8.8842298, '2024-05-13 16:51:35', '2024-05-13 16:51:35', '6'),
('heruyd123', 'Heruy Damtew', 'M', '1998-12-04 00:00:00', 251929411967, '$2a$10$VHCVqWqbh9owjvbHAyvBguwaflOI2UOi0lRyfFfk704OM71DDI9Mu', 'Reflection without mirror ', 1, 38.642235, 1, 8.9278257, '2024-05-12 18:09:51', '2024-05-12 18:09:51', '6'),
('newuser10', 'newuser10', 'M', '2008-05-16 00:00:00', 251987655657, '$2a$10$CVZJ2grKk0xJj21bOkvCBOpV1DQr3lxqiqSmaWyZcv8eYU57OYntO', 'khgck', 1, -122.084, 1, 37.4219983, '2024-05-12 18:50:43', '2024-05-12 18:50:43', '1'),
('newuser20', 'newuser20', 'M', '2008-05-16 00:00:00', 251986896646, '$2a$10$rKO5xMoNxbdILI6dt/AGmuIQQ/aSiYmDAZFdIHr4ZfU53iqr8LXGK', 'jtrdjd', 1, -122.084, 1, 37.4219983, '2024-05-12 19:04:32', '2024-05-12 19:04:32', '1'),
('newuser30', 'nnnn', 'M', '2008-05-16 00:00:00', 251987656787, '$2a$10$7M/fCsxd.mjDSaoi8Mek0e1o61iqg2l0P3mAxb3moTnNdtU1KNooC', 'jf', 1, -122.084, 1, 37.4219983, '2024-05-12 19:10:18', '2024-05-12 19:10:18', '1'),
('trialacc123', 'trial account', 'F', '2008-05-16 00:00:00', 251911235032, '$2a$10$UGVfIhZmtkn/CopBKnDkVOyaYsdoYHroKeXptNsjGRampzZdDzNa6', 'trial ac', 1, 38.642234, 1, 8.9278275, '2024-05-12 19:06:16', '2024-05-12 19:06:16', '4');

-- --------------------------------------------------------

--
-- Table structure for table `user-verification-images`
--

CREATE TABLE `user-verification-images` (
  `image` varchar(200) NOT NULL,
  `status` varchar(45) NOT NULL DEFAULT 'pending',
  `user_username` varchar(45) NOT NULL,
  `sample-verification-images_id` int NOT NULL,
  `id` int NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `user-verification-images`
--

INSERT INTO `user-verification-images` (`image`, `status`, `user_username`, `sample-verification-images_id`, `id`) VALUES
('image-1715528666758.jpg', 'declined', 'wamanuel', 79, 19),
('image-1715438938346.jpg', 'declined', 'trialacc123', 68, 18),
('image-1715399985182.jpg', 'verified', 'heruyd321@', 67, 17),
('image-1715336028235.jpg', 'verified', 'newuser01', 67, 16),
('image-1715194816717.jpg', 'verified', 'heruyd321', 66, 15),
('image-1715156586983.png', 'verified', 'amanuelwt', 66, 14),
('image-1715156576716.png', 'declined', 'amanuel', 66, 13),
('image-1715156223847.png', 'declined', 'amanuel', 66, 12),
('image-1715156208071.png', 'verified', 'amanuelwt', 66, 11),
('image-1715528821927.jpg', 'verified', 'wamanuel', 80, 20),
('image-1715529017517.jpg', 'verified', 'wamanuel', 80, 21),
('image-1715529054520.jpg', 'declined', 'trialacc123', 77, 22),
('image-1715529698081.jpg', 'declined', 'trialacc123', 79, 23),
('image-1715529814920.jpg', 'declined', 'trialacc123', 80, 24),
('image-1715531568337.jpg', 'declined', 'trialacc123', 78, 25),
('image-1715533937061.jpg', 'verified', 'wondeamanuel', 77, 26),
('image-1715533988657.jpg', 'verified', 'wondeamanuel', 77, 27),
('image-1715537525088.jpg', 'declined', 'heruyd123', 77, 28),
('image-1715537697788.jpg', 'verified', 'heruyd123', 78, 29),
('image-1715539343790.jpg', 'verified', 'newuser01', 71, 30),
('image-1715539894587.jpg', 'declined', 'newuser10', 78, 31),
('image-1715540069887.jpg', 'verified', 'newuser10', 79, 32),
('image-1715540732223.jpg', 'declined', 'newuser20', 77, 33),
('image-1715540837501.jpg', 'declined', 'newuser20', 80, 34),
('image-1715540872596.jpg', 'verified', 'newuser20', 78, 35),
('image-1715540922536.jpg', 'verified', 'trialacc123', 71, 36),
('image-1715541060609.jpg', 'declined', 'newuser30', 79, 37),
('image-1715541108604.jpg', 'verified', 'newuser30', 80, 38),
('image-1715541326669.jpg', 'verified', 'newuser30', 80, 39),
('image-1715541432885.jpg', 'declined', 'newuser30', 79, 40),
('image-1715541463563.jpg', 'declined', 'newuser30', 79, 41),
('image-1715541521555.jpg', 'verified', 'newuser30', 80, 42),
('image-1715574283391.jpg', 'verified', 'amanuel', 79, 43);

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
(175, 'picture adding trial 69mbps', '2024-05-15 08:30:35', '2024-05-15 08:30:35', NULL, '2024-05-15 09:00:00', '2024-05-15 09:30:00'),
(176, '41mbps all 5 picture questions trial', '2024-05-15 09:15:44', '2024-05-15 09:15:44', NULL, '2024-05-15 11:00:00', '2024-05-16 13:30:00');

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
  ADD KEY `index-user-2-1` (`user-2`,`user-1`) INVISIBLE,
  ADD KEY `index-conversaton-id` (`conversation-id`,`status`);

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
  ADD KEY `UNIQUE_deviceId` (`deviceId`) USING BTREE;

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
  ADD PRIMARY KEY (`id-messages`,`conversation-id`),
  ADD KEY `fk_message_user1_idx` (`sender`),
  ADD KEY `fk_Message_Conversatoin_conversaton-id` (`conversation-id`);

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
-- Indexes for table `profiledata`
--
ALTER TABLE `profiledata`
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
  ADD PRIMARY KEY (`id`),
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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1884;

--
-- AUTO_INCREMENT for table `choices`
--
ALTER TABLE `choices`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=881;

--
-- AUTO_INCREMENT for table `conversation`
--
ALTER TABLE `conversation`
  MODIFY `conversation-id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `custom-questions`
--
ALTER TABLE `custom-questions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `deleted-profile-images`
--
ALTER TABLE `deleted-profile-images`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `message`
--
ALTER TABLE `message`
  MODIFY `id-messages` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `pd-rcv-que`
--
ALTER TABLE `pd-rcv-que`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `profile-images`
--
ALTER TABLE `profile-images`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=172;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=457;

--
-- AUTO_INCREMENT for table `sample-verification-images`
--
ALTER TABLE `sample-verification-images`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=81;

--
-- AUTO_INCREMENT for table `user-verification-images`
--
ALTER TABLE `user-verification-images`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `windows`
--
ALTER TABLE `windows`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=177;

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
  ADD CONSTRAINT `fk_kindOfPerson_profileData1` FOREIGN KEY (`username`) REFERENCES `profiledata` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `message`
--
ALTER TABLE `message`
  ADD CONSTRAINT `fk_Message_Conversatoin_conversaton-id` FOREIGN KEY (`conversation-id`) REFERENCES `conversation` (`conversation-id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_message_user1` FOREIGN KEY (`sender`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

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
-- Constraints for table `profiledata`
--
ALTER TABLE `profiledata`
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
