GM = GM or GAMEMODE
function GM:SetupDatabase()
	-- Which method of storage: sqlite, tmysql4, mysqloo
	nut.db.module = "mysqloo"
	-- The hostname for the MySQL server.
	nut.db.hostname = "127.0.0.1"
	-- The username to login to the database.
	nut.db.username = "root"
	-- The password that is associated with the username.
	nut.db.password = "nt50857197-"
	-- The database that the user should login to.
	nut.db.database = "nutscript"
	-- The port for the database, you shouldn't need to change this.
	nut.db.port = 3306
end