AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end

    local sql = ([[
        CREATE TABLE IF NOT EXISTS %s (
            %s INT UNSIGNED NOT NULL AUTO_INCREMENT,
            %s VARCHAR(64) NOT NULL,
            %s VARCHAR(128) DEFAULT NULL,
            %s TIMESTAMP NULL DEFAULT NULL,
            %s TIMESTAMP NULL DEFAULT NULL,
            PRIMARY KEY (%s),
            UNIQUE KEY `uq_identifier` (%s)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=%d;
    ]]):format(
        PID.Sql.tableName, PID.Sql.columns.id, PID.Sql.columns.identifier, PID.Sql.columns.name, PID.Sql.columns.firstSeen, PID.Sql.columns.lastSeen,
        PID.Sql.columns.id, PID.Sql.columns.identifier, Config.Assignment.startId or 1
    )

    MySQL.query(sql, {}, function()
        PID.Log('INFO', ('ready (v%s) table `%s`'):format(Config.Version, Config.Database.table))
    end)
end)
