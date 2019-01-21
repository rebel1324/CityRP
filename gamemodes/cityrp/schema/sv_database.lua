GM = GM or GAMEMODE

-- If you want to.
function GM:SetupDatabase()
	-- Which method of storage: sqlite, tmysql4, mysqloo
	nut.db.module = "mysqloo"
	-- The hostname for the MySQL server.
	nut.db.hostname = "118.216.92.147"
	-- The username to login to the database.
	nut.db.username = "rebel1324"
	-- The password that is associated with the username.
	nut.db.password = "HceVjRS8b6HC@dUnZF!RjZ!#3Y9ZCGkvsXjGHRyegytFFgBtZ^@EmPf*gFPSkaKUwYw2%g3mD2Q#JGjkhnctESPp#q$QRJK$6PT"
	-- The database that the user should login to.
	nut.db.database = "nutscript"
	-- The port for the database, you shouldn't need to change this.
	nut.db.port = 3306
end