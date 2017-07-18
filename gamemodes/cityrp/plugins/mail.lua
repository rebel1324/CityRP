print("fugg:dd")
/*local PLUGIN = PLUGIN
PLUGIN.name = "Mail"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "You've got mail."


do
	if (SERVER) then
		local MYSQL_CREATE_TABLES = [[
CREATE TABLE IF NOT EXISTS `nut_mails` (
	`_mailID` int(20) NOT NULL AUTO_INCREMENT,
	`_from` int(11) NOT NULL,
	`_to` int(11) NOT NULL,
	`_title` text NOT NULL,
	`_desc` text NOT NULL,
	`_attachment` text NOT NULL,
	PRIMARY KEY (`_mailID`)
);
		]]
		local SQLITE_CREATE_TABLES = [[
CREATE TABLE IF NOT EXISTS `nut_mails` (
	`_mailID` INTEGER PRIMARY KEY AUTOINCREMENT,
	`_from` INTEGER,
	`_to` INTEGER,
	`_title` TEXT,
	`_desc` TEXT,
	`_attachment` TEXT,
);
		]]

		function PLUGIN:OnLoadTables()
			if (nut.db.module) then
				nut.db.query(MYSQL_CREATE_TABLES)
			else
				nut.db.query(SQLITE_CREATE_TABLES)
			end
		end

		function PLUGIN:CharacterPreSave(char)
			savestash(char)
		end
        
	    function PLUGIN:PreCharDelete(client, char)
	    	-- get character stash items and eradicate item data from the DATABASE.
	    	if (char) then
			end
	    end
	end
end

local charMeta = getmetatable("Character")

nut.mail = nut.mail or {}
nut.mail.list = nut.mail.list or {}
nut.mail.char = nut.mail.char or {}

function nut.mail.loadMails(character)
end

function nut.mail.get(character)
end

function nut.mail.load(mailID)
end

function nut.mail.clearMails(character)
end

function nut.mail.send(name, desc, attachments, to, from)
    if (!to) then return false end

	nut.db.insertTable({
	    _from = from,
	    _to = to or 0,
	    _title = name or "No Title",
	    _desc = desc or "No Description",
	    _attachment = attachments or "",
	}, function(data, mailID)
        local maildaemon = {

						local data = util.JSONToTable(v._items or "[]")
        }

		nut.mail.list[mailID] = {
            
        }
	end, "mails")
end

function nut.mail.delete(mailID)
en
d
*/