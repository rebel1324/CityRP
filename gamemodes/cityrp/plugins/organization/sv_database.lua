
local MYSQL_CREATE_TABLES = [[
CREATE TABLE IF NOT EXISTS `nut_organization` (
	`_id` INT(12) NOT NULL AUTO_INCREMENT,
	`_name` VARCHAR(32) NOT NULL,
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



do
	function nut.org.join(orgID, charID, char)
		local d = deferred.new()

		if (
			not orgID or not charID or 
			not isnumber(orgID) or not isnumber(charID)
		) then
			return d:reject()
		end

		char = char or nut.char.loaded[charID]

		if (not charID) then
			d:reject()
		end

		if (MYSQLOO_PREPARED) then
            local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
            
			nut.db.preparedCall("orgMember", function(data)
				d:resolve(data)
			end, orgID, charID, rank, char:getName())
		else
            nut.db.insertTable({
                _orgID = orgID,
                _charID = charID, 
                _rank = rank,
                _name = char:getName()
            }, function(succ) 
				d:resolve(succ)
            end, "orgmembers")
		end

		return d
	end

	function nut.org.setName(id, name)
		local d = deferred.new()

		if (not id or not name) then
			return d:reject()
		end

		if (MYSQLOO_PREPARED) then
            local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())

			nut.db.preparedCall("orgName", function(data) d:resolve(data) end, name, id)
		else
			nut.db.updateTable({
				_name = text,
			}, function()
				d:resolve()
			end, "organization", "_id = ".. self.id)
		end

		return d
	end

	function nut.org.charRank(charID, orgID, rank)
		local d = deferred.new()

		if (not charID or not orgID or not rank) then
			return d:reject()
		end

        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
		if (MYSQLOO_PREPARED) then
			nut.db.preparedCall("orgCharRank", function(data) d:resolve(data) end, rank, id, orgID)
		else
            nut.db.updateTable({
                _rank = rank,
            }, function()
				d:resolve()
			end, "orgmembers", "_charID = ".. charID .. " AND _orgID = " .. orgID)
		end

		return d
	end

    function nut.org.create()
        local d = deferred.new()

        local ponNull = pon.encode({})

		local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        nut.db.insertTable({
            _name = ORGANIZATION_DEFUALT_NAME,
            _lastModify = timeStamp,
            _timeCreated = timeStamp,
            _level = 1, 
            _money = ORGANIZATION_INITIAL_MONEY, 
            _experience = 0,
            _data = ponNull
        }, function(succ, orgID) 
            if (succ != false) then
                local org = nut.org.new()
                org.id = orgID
                nut.org.loaded[orgID] = org

                if (callback) then
                    org:sync()
                    d:resolve(org)
                end
            end
        end, "organization")

        return d
    end

    function nut.org.delete(id)
        local org = nut.org.loaded[id]
        
        if (org) then
            local affectedPlayers = {}

            for k, v in ipairs(player.GetAll()) do
                local char = v:getChar()

                if (char) then
                    local charOrg = char:getOrganization()

                    if (charOrg == id) then
                        char:setData("organization", nil, nil, player.GetAll())
                        char:setData("organizationRank", nil, nil, player.GetAll())

                        table.insert(affectedPlayers, v)
                    end
                end
            end

            hook.Run("OnOranizationDeleted", org, affectedPlayers)

            org:unsync()

            nut.org.loaded[id] = nil
            nut.db.query("DELETE FROM nut_organization WHERE _id IN ("..org.id..")")

            return true
        else
            return false, "invalidOrg"
        end
    end

    function nut.org.syncAll(recipient)
        local orgData = {}
        for k, v in pairs(nut.org.loaded) do
            orgData[k] = v:getSyncInfo()
        end
        netstream.Start(recipient, "nutOrgSyncAll", orgData)
    end

    function nut.org.purge(callback)
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time() - ORGANIZATION_AUTO_DELETE_TIME)
        
        nut.db.query("DELETE FROM nut_organization WHERE _lastModify <= '".. timeStamp .."'", function(data, data2)
            if (callback) then
                callback()
            end
        end)
    end

    function nut.org.load(id, callback)
        local org = nut.org.new()

        nut.db.query("SELECT _id, _name, _level, _experience, _data FROM nut_organization WHERE _id IN ("..id..")", function(data)
            if (data) then
                for k, v in ipairs(data) do
                    local org = nut.org.new()
                    org.id = tonumber(v._id)
                    org.name = v._name
                    org.level = tonumber(v._level)
                    org.experience = tonumber(v._experience)
                    org.data = pon.decode(v._data)

                    nut.org.loaded[org.id] = org

                    nut.db.query("SELECT _orgID, _charID, _rank, _name FROM nut_orgmembers WHERE _orgID IN ("..org.id..")", function(data)
                        if (data) then
                            for k, v in ipairs(data) do
                                local rank = tonumber(v._rank)
                                org.members[rank] = org.members[rank] or {}
                                org.members[rank][tonumber(v._charID)] = v._name
                            end
                        end

                        if (callback) then
                            callback(org)
                        end
                    end)
                end
            end
        end)
    end
    
    function nut.org.loadAll(callback)
        local org = nut.org.new()

        nut.db.query("SELECT _id, _name, _level, _experience, _data FROM nut_organization", function(data)
            if (data) then
                for k, v in ipairs(data) do
                    local org = nut.org.new()
                    org.id = tonumber(v._id)
                    org.name = v._name
                    org.level = tonumber(v._level)
                    org.experience = tonumber(v._experience)
                    org.data = pon.decode(v._data)

                    nut.org.loaded[org.id] = org

                    nut.db.query("SELECT _orgID, _charID, _rank, _name FROM nut_orgmembers WHERE _orgID IN ("..org.id..")", function(data)
                        if (data) then
                            for k, v in ipairs(data) do
                                local rank = tonumber(v._rank)
                                org.members[rank] = org.members[rank] or {}
                                org.members[rank][tonumber(v._charID)] = v._name
                            end
                        end

                        if (callback) then
                            callback(org)
                        end
                    end)
                end
            end
        end)
    end
end

function PLUGIN:RegisterPreparedStatements()
	MsgC(Color(0, 255, 0), "[Nutscript] ADDED ORGANIZATION PREPARED STATEMENTS\n")
	nut.db.prepare("orgLastModify", "UPDATE nut_organization SET _lastModify = ? WHERE _id = ?", {MYSQLOO_STRING, MYSQLOO_INTEGER})
	nut.db.prepare("orgName", "UPDATE nut_organization SET _name = ? WHERE _id = ?", {MYSQLOO_STRING, MYSQLOO_INTEGER})
	nut.db.prepare("orgMoney", "UPDATE nut_organization SET _money = ? WHERE _id = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER})
	nut.db.prepare("orgLevel", "UPDATE nut_organization SET _level = ? WHERE _id = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER})
	nut.db.prepare("orgData", "UPDATE nut_organization SET _data = ? WHERE _id = ?", {MYSQLOO_STRING, MYSQLOO_INTEGER})
	nut.db.prepare("orgCharRank", "UPDATE nut_orgmembers SET _rank = ? WHERE _charID = ? AND _orgID = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER, MYSQLOO_INTEGER})
	nut.db.prepare("orgMember", "INSERT INTO nut_orgmembers (_orgID, _charID, _rank, _name) VALUES (?, ?, ?, ?)", {
		MYSQLOO_INTEGER,
		MYSQLOO_INTEGER,
		MYSQLOO_INTEGER,
		MYSQLOO_STRING,
	})
end