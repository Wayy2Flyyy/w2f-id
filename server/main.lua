AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end

    local C = Config.Database.columns
    local sql = ([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `%s` INT UNSIGNED NOT NULL AUTO_INCREMENT,
            `%s` VARCHAR(64) NOT NULL,
            `%s` VARCHAR(128) DEFAULT NULL,
            `%s` TIMESTAMP NULL DEFAULT NULL,
            `%s` TIMESTAMP NULL DEFAULT NULL,
            PRIMARY KEY (`%s`),
            UNIQUE KEY `uq_identifier` (`%s`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=%d;
    ]]):format(
        Config.Database.table, C.id, C.identifier, C.name, C.firstSeen, C.lastSeen,
        C.id, C.identifier, Config.Assignment.startId or 1
    )

    MySQL.query(sql, {}, function()
        PID.Log('INFO', ('ready (v%s) table `%s`'):format(Config.Version, Config.Database.table))
    end)
end)
