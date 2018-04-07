
local MYSQL_CREATE_TABLES = [[
CREATE TABLE IF NOT EXISTS `nut_organization` (
	`_id` INT(11) NOT NULL AUTO_INCREMENT,
	`_name` TEXT(32) NOT NULL,
	`_members` TEXT NOT NULL,
	`_level` INT(12) NOT NULL,
	`_experience` FLOAT(32) NOT NULL,
	`_lastModify` DATETIME NOT NULL,
	`_data` TEXT NOT NULL,
	PRIMARY KEY (`_id`)
);

CREATE TABLE IF NOT EXISTS `nut_orgmembers` (
	`_orgID` INT(11) NOT NULL,
	`_charID` INT(11) NOT NULL,
	`_rank` INT(1) NOT NULL,
	`_name` TEXT NOT NULL,
	PRIMARY KEY (`_orgID`,`_charID`)
);
]]

local SQLITE_CREATE_TABLES = [[
CREATE TABLE IF NOT EXISTS nut_organization (
	_id integer PRIMARY KEY AUTOINCREMENT,
	_name text,
	_members text,
	_level integer,
	_experience float,
	_lastModify datetime,
	_data text
);

CREATE TABLE IF NOT EXISTS nut_orgmembers (
	_orgID integer,
	_charID integer,
	_rank integer,
	_name text
);
]]

local DROP_QUERY = [[
DROP TABLE IF EXISTS nut_organization;
DROP TABLE IF EXISTS nut_orgmembers;
]]

function PLUGIN:OnLoadTables()
	if (nut.db.object) then
		nut.db.query(MYSQL_CREATE_TABLES)
	else
		nut.db.query(SQLITE_CREATE_TABLES)
	end
end

function PLUGIN:OnWipeTables()
	if (nut.db.module) then
		local queries = string.Explode(";", DROP_QUERY)

		for i = 1, #queries do
			nut.db.query(queries[i], callback)
		end
	else
		nut.db.query(DROP_QUERY)
	end
end