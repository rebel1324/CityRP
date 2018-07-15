
local MYSQL_CREATE_TABLES = [[
CREATE TABLE IF NOT EXISTS `nut_organization` (
	`_id` INT(12) NOT NULL AUTO_INCREMENT,
	`_name` INT(32) NOT NULL,
	`_level` INT(12) NOT NULL,
	`_experience` INT(12) NOT NULL,
	`_money` INT(12) NOT NULL,
	`_lastModify` DATETIME NOT NULL,
	`_timeCreated` DATETIME NOT NULL,
	`_data` VARCHAR(2048) NOT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`_id`),
	UNIQUE INDEX `_id` (`_id`)
);
CREATE TABLE IF NOT EXISTS `nut_orgmembers` (
	`_orgID` INT(12) NOT NULL,
	`_charID` INT(12) NOT NULL,
	`_rank` INT(1) NOT NULL,
	`_name` VARCHAR(70) NOT NULL COLLATE 'utf8mb4_general_ci'
)]]

local SQLITE_CREATE_TABLES = [[
CREATE TABLE IF NOT EXISTS nut_organization (
	_id integer PRIMARY KEY AUTOINCREMENT,
	_name text,
	_level integer,
	_experience float,
	_money float,
	_lastModify datetime,
	_timeCreated datetime,
	_data text
);

CREATE TABLE IF NOT EXISTS nut_orgmembers (
	_orgID integer,
	_charID integer,
	_rank integer,
	_name text
);]]

local DROP_QUERY = [[
DROP TABLE IF EXISTS nut_organization;
DROP TABLE IF EXISTS nut_orgmembers]]

function PLUGIN:OnLoadTables()
	if (nut.db.object) then
		local queries = string.Explode(";", MYSQL_CREATE_TABLES)

		for i = 1, #queries do
			nut.db.query(queries[i], callback)
		end
	else
		nut.db.query(SQLITE_CREATE_TABLES)
	end
end

function PLUGIN:OnWipeTables()
	if (nut.db.object) then
		local queries = string.Explode(";", DROP_QUERY)

		for i = 1, #queries do
			nut.db.query(queries[i], callback)
		end
	else
		nut.db.query(DROP_QUERY)
	end
end