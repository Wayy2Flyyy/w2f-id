CREATE TABLE IF NOT EXISTS `user_permanent_ids` (
    `permanent_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `identifier`   VARCHAR(64)  NOT NULL,
    `player_name`  VARCHAR(128) DEFAULT NULL,
    `first_seen`   TIMESTAMP    NULL DEFAULT NULL,
    `last_seen`    TIMESTAMP    NULL DEFAULT NULL,
    PRIMARY KEY (`permanent_id`),
    UNIQUE KEY `uq_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1;
