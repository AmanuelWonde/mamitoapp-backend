DELIMITER $$
DROP PROCEDURE IF EXISTS `AddVerificationImage`$$
CREATE PROCEDURE `AddVerificationImage`(IN `image` VARCHAR(200), IN `sampleImageId` INT, IN `username` VARCHAR(50))
BEGIN
INSERT INTO `user-verification-images`(image, `sample-verification-images_id`, user_username)
VALUES(image, sampleImageId, username);
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `FindMatches`$$
CREATE PROCEDURE `FindMatches`(IN `windowId` INT)
BEGIN
SELECT answers.*, `user`.profile_image, questions.value
FROM answers
JOIN `user` ON `user`.username = answers.user_username
JOIN questions ON questions.id = answers.question_id
WHERE answers.window_id = windowId;
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `GetCurrentOrNextWindow`$$
CREATE PROCEDURE `GetCurrentOrNextWindow`()
BEGIN
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
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `GetSampleImages`$$
CREATE PROCEDURE `GetSampleImages`(IN `inputGender` VARCHAR(50))
BEGIN
    SELECT * FROM `sample-verification-images` 
    WHERE gender = inputGender;
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `GetWindow`$$
CREATE PROCEDURE `GetWindow`()
BEGIN
SELECT 
id, name, `status`,
    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') AS created_at,
    DATE_FORMAT(start_at, '%Y-%m-%d %H:%i:%s') AS start_at,
    DATE_FORMAT(end_at, '%Y-%m-%d %H:%i:%s') AS end_at 
   FROM windows;
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `GetWindowId`$$
CREATE PROCEDURE `GetWindowId`()
BEGIN
    SELECT *
    FROM windows
    WHERE CURRENT_TIMESTAMP BETWEEN 
    start_at AND
    end_at;
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `InsertChoice`$$
CREATE PROCEDURE `InsertChoice`(IN `questionId` INT, IN `choiceValue` VARCHAR(100), IN `image` VARCHAR(255))
    DETERMINISTIC
BEGIN
    INSERT INTO choices (questions_id, choice, image)
    VALUES (questionId, choiceValue, image);
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `InsertQuestion`$$
CREATE PROCEDURE `InsertQuestion`(IN `question` VARCHAR(100), IN `windowId` INT, IN `questionValue` DECIMAL, OUT `insertedId` INT)
BEGIN
    INSERT INTO questions (question, question_value, windows_id)
    VALUES (question, questionValue, windowId);
    SET insertedId = LAST_INSERT_ID();
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `InsertSampleImage`$$
CREATE PROCEDURE `InsertSampleImage`(IN `image` VARCHAR(200), IN `gender` VARCHAR(45))
BEGIN
INSERT INTO `sample-verification-images`(image, gender)
VALUES (image, gender);
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `InsertUserAnswers`$$
CREATE PROCEDURE `InsertUserAnswers`(IN `windowId` INT, IN `userName` VARCHAR(255), IN `questionId` INT, IN `choiceId` INT)
BEGIN
    INSERT INTO answers (window_id, users_username, question_id, choice_id)
    VALUES (windowId, userName, questionId, choiceId);
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `InsertWindow`$$
CREATE PROCEDURE `InsertWindow`(IN `name` VARCHAR(50), IN `startDate` DATETIME, IN `endDate` DATETIME, OUT `insertedId` INT)
BEGIN
    INSERT INTO windows (name, start_at, end_at)
    VALUES (name, startDate, endDate);
      SET insertedId = LAST_INSERT_ID();
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `UpdateWindow`$$
CREATE PROCEDURE `UpdateWindow`(IN `windowId` INT, IN `newName` VARCHAR(200), IN `newStartAt` DATETIME, IN `newEndAt` DATETIME)
BEGIN
UPDATE windows
    SET
        name = newName,
        start_at = newStartAt,
        end_at = newEndAt
    WHERE
        id = windowId;
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `ValidateUserImages`$$
CREATE PROCEDURE `ValidateUserImages`(IN `validateStatus` VARCHAR(50), IN `username` VARCHAR(50), IN `sampleImageId` INT)
BEGIN
    UPDATE `user-verification-images`
    SET `status` = validateStatus
    WHERE `user-verification-images`.`user_username` = username 
    AND `user-verification-images`.`sample-verification-images_id` = sampleImageId;
END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `ViewUserVerificationImages`$$
CREATE PROCEDURE `ViewUserVerificationImages`()
BEGIN
SELECT uvi.`sample-verification-images_id`  AS sampleImageId, uvi.image, uvi.status, uvi.user_username AS username, svi.image AS sampleImage
FROM `user-verification-images` uvi
INNER JOIN `sample-verification-images` svi ON uvi.`sample-verification-images_id` = svi.id
WHERE uvi.status = 'pending';


END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `CurrentWindowQuestions`$$
CREATE PROCEDURE `CurrentWindowQuestions`(IN `windowId` INT)
BEGIN
    SELECT q.question AS question, q.id AS id, q.question_value AS `value`,
        JSON_ARRAYAGG(JSON_OBJECT('id', c.id, 'choice', c.choice, 'image', c.image)) AS choices
    FROM questions q
    LEFT JOIN choices c ON q.id = c.questions_id
    WHERE q.windows_id = windowId
    GROUP BY q.id;
END$$
DELIMITER ;
