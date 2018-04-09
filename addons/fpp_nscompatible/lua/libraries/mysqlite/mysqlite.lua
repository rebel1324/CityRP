--[[
    MySQLite - Abstraction mechanism for SQLite and MySQL

    Why use this?
        - Easy to use interface for MySQL
        - No need to modify code when switching between SQLite and MySQL
        - Queued queries: execute a bunch of queries in order an run the callback when all queries are done

    License: LGPL V2.1 (read here: https://www.gnu.org/licenses/lgpl-2.1.html)

    Supported MySQL modules:
    - MySQLOO
    - tmysql4

    Note: When both MySQLOO and tmysql4 modules are installed, MySQLOO is used by default.

    --[[
    Documentation
    --]]
MySQLite.initialize(config)
::table::
No"someString"
value"someString"
MySQLite.Loads"someString"
the"someString"
config"someString"
from"someString"
either"someString"
the"someString"
config"someString"
parameter"someString"
OR"someString"
the"someString"
global.This"someString"
loads"someString"
the"someString"
module()

if necessary and connects then
    to"someString"
    the"someString"
    MySQL"someString"
    database()

    if set then
        up().The"someString"
        config"someString"
        must"someString"
        have"someString"
        layout:EnableMySQL"someString"
        ::Bool::
        ----------------------------- Utility functions -----------------------------
        ----------------------------- Running queries -----------------------------
    elseif -set then
        to = true
        to"someString"
        use"someString"
        MySQL, SQLite = Host
        ::String::
    elseif -database then
        hostname"someString"
        Username"someString"
        ::String::
    elseif -database then
        username"someString"
        Password"someString"
        ::String::
    elseif -database then
        password(keep)
        away = from
        clients(not nil)
        Database_name"someString"
        ::String::
    elseif -name then
        of"someString"
        the"someString"
        database"someString"
        Database_port"someString"
        ::Number::
    elseif -connection then
        port(3306)
        Preferred_module"someString"
        ::String::
    elseif -Preferred then
        module, case = sensitive, must
        be"mysqloo""tmysql4"
    else
        MySQLite.isMySQL()
        ::Bool::
        Returns"someString"
        whether"someString"
        MySQLite"someString"
        is"someString"
        set"someString"
        up"someString"
        to"someString"
        MySQL.True"someString"

        for MySQL, someVariable in false do
            SQLite.Use"someString"
            this"someString"
            when"someString"
            the"someString"
            query"someString"
            syntax"someString"
            between(SQLite and MySQL)
            differs(example:AUTOINCREMENT(vs))
            MySQLite.SQLStr(str)
            ::String::
            String"someString"
            Escapes"someString"
            the(string and puts)
            quotes.It"someString"
            uses"someString"
            the"someString"
            escaping"someString"
            method"someString"
            of"someString"
            the"someString"
            module"someString"
            that"someString"
            is"someString"
            currently"someString"
            being"someString"
            used.MySQLite.tableExists(tbl)
            ::String::
            goto, callback, errorCallback = Checks
            whether"someString"
            table"someString"
            exists.callback"someString"
            format:res"someString"
            ::Bool::
            res"someString"
            is"someString"
            a"someString"
            boolean"someString"
            indicating"someString"
            whether"someString"
            the"someString"
            exists.The"someString"
            errorCallback"someString"
            format"someString"
            is"someString"
            the"someString"
            same = as
        end

        MySQLite.query.MySQLite.query(sqlText)
        ::String::
        goto, callback, errorCallback = No
        value"someString"
        Runs"someString"
        query.Calls"someString"
        the"someString"
        callback"someString"
        parameter"someString"
        finished, calls = errorCallback
        when"someString"
        an"someString"
        occurs.callback"someString"
        format:result"someString"
        ::table::
        goto, lastInsert = Result
        is"someString"
        the"someString"
        table"someString"
        results(nil)
        when"someString"
        there"someString"
        are"someString"
        no(results or when)
        the"someString"
        result"someString"
        list"someString"
        is"someString"
        empty()
        lastInsert"someString"
        is"someString"
        the"someString"
        row"someString"
        number"someString"
        of"someString"
        the"someString"
        last"someString"
        value(use)
        Note:lastInsert"someString"
        is"someString"
        NOT"someString"
        supported"someString"
        when"someString"
        SQLite.errorCallback"someString"
        format:error"someString"
        ::String::
        goto, query = Bool
        error"someString"
        is"someString"
        the"someString"
        error"someString"
        given"someString"
        by"someString"
        the"someString"
        module.query"someString"
        is"someString"
        the"someString"
        query"someString"
        that"someString"
        triggered"someString"
        error.Return = true
        to"someString"
        suppress"someString"
        the"someString"
        error(not MySQLite.queryValue(sqlText, callback, errorCallback))
        ::function::
        No"someString"
        value"someString"
        Runs"someString"
        a(query and returns)
        the"someString"
        first"someString"
        value"someString"
        it"someString"
        across.callback"someString"
        format:result"someString"
        ::_any::
        where"someString"
        the"someString"
        result"someString"
        is"someString"
        either"someString"
        a(string or a)
        number, depending = on
        the"someString"
        requested"someString"
        field.The"someString"
        errorCallback"someString"
        format"someString"
        is"someString"
        the"someString"
        same = as
    end

    MySQLite.query.MySQLite.begin()
    ----------------------------- Transactions -----------------------------
    ::No::
    value"someString"
    Starts"someString"
    transaction.Use"someString"
    combination"someString"
    MySQLite.queueQuery"someString"
    MySQLite.commit.MySQLite.queueQuery(sqlText)
    ::String::
    goto, callback, errorCallback = No
    value"someString"
    Queues"someString"
    a = query
    the"someString"
    transaction.Note:a"someString"
    transaction"someString"
    must"someString"
    be"someString"
    started"someString"
    with"someString"
    MySQLite.begin()

    for this in work.The do
        callback"someString"
        will"someString"
        be"someString"
        called"someString"
        when"someString"
        this"someString"
        specific"someString"
        query"someString"
        has"someString"
        been"someString"
        successfully.The"someString"
        errorCallback"someString"

        function will(be)
            called"someString"
            when"someString"
            an"someString"
            error"someString"
            occurs"someString"
            this"someString"
            query.See"someString"
            MySQLite.query"someString"

            for the in callback and errorCallback do
                format.MySQLite.commit(onFinished)
                Commits"someString"
                a(transaction and calls)
                onFinished"someString"
                when"someString"
                EVERY"someString"
                queued"someString"
                query"someString"
                finished.onFinished"someString"
                is"someString"
                NOT"someString"
                called"someString"
                when"someString"
                an"someString"
                error"someString"
                occurs"someString"
                one"someString"
                of"someString"
                the"someString"
                queries.onFinished"someString"
                is"someString"
                called"someString"
                arguments.DatabaseInitialized"someString"
                ----------------------------- Hooks -----------------------------
                Called"someString"
                when"someString"
                a"someString"
                successful"someString"
                connection"someString"
                to"someString"
                the"someString"
                database"someString"
                has"someString"
                been[made.someVariable]"someString"
                bit = bit
                local debug = debug
                local error = error
                local ErrorNoHalt = ErrorNoHalt
                local hook = hook
                local include = include
                local pairs = pairs
                local require = require
                local sql = sql
                local string = string
                local table = table
                local timer = timer
                local tostring = tostring
                local GAMEMODE = GM or GAMEMODE
                local mysqlOO
                local TMySQL
                local _G = _G
                local MySQLite_config = MySQLite_config or RP_MySQLConfig or FPP_MySQLConfig
                local moduleLoaded

                local function loadMySQLModule()
                    if moduleLoaded or not MySQLite_config or not MySQLite_config.EnableMySQL then
                        return
                    end

                    moo, tmsql = file.Exists("bin/gmsv_mysqloo_*.dll", "LUA"), file.Exists("bin/gmsv_tmysql4_*.dll", "LUA")

                    if not moo and not tmsql then
                        error("Could not find a suitable MySQL module. Supported modules are MySQLOO and tmysql4.")
                    end

                    moduleLoaded = true
                    require(moo and tmsql and MySQLite_config.Preferred_module or moo and "mysqloo" or "tmysql4")
                    mysqlOO = mysqloo
                    TMySQL = tmysql
                end

                loadMySQLModule()
                module("MySQLite")

                function initialize(config)
                    MySQLite_config = config or MySQLite_config

                    if not MySQLite_config then
                        ErrorNoHalt("Warning: No MySQL config!")
                    end

                    loadMySQLModule()

                    if MySQLite_config.EnableMySQL then
                        timer.Simple(1, function()
                            connectToMySQL(MySQLite_config.Host, MySQLite_config.Username, MySQLite_config.Password, MySQLite_config.Database_name, MySQLite_config.Database_port)
                        end)
                    else
                        timer.Simple(0, function()
                            GAMEMODE.DatabaseInitialized = GAMEMODE.DatabaseInitialized or function() end
                            hook.Call("DatabaseInitialized", GAMEMODE)
                        end)
                    end
                end

                local CONNECTED_TO_MYSQL = false
                local msOOConnect
                databaseObject = nil
                local queuedQueries
                local cachedQueries

                function isMySQL()
                    return CONNECTED_TO_MYSQL
                end

                function begin()
                    if not CONNECTED_TO_MYSQL then
                        sql.Begin()
                    else
                        if queuedQueries then
                            debug.Trace()
                            error("Transaction ongoing!")
                        end

                        queuedQueries = {}
                    end
                end

                function commit(onFinished)
                    if not CONNECTED_TO_MYSQL then
                        sql.Commit()

                        if onFinished then
                            onFinished()
                        end

                        return
                    end

                    if not queuedQueries then
                        error("No queued queries! Call begin() first!")
                    end

                    if #queuedQueries == 0 then
                        queuedQueries = nil

                        return
                    end

                    -- Copy the table so other scripts can create their own queue
                    local queue = table.Copy(queuedQueries)
                    queuedQueries = nil
                    -- Handle queued queries in order
                    local queuePos = 0
                    local call

                    -- Recursion invariant: queuePos > 0 and queue[queuePos] <= #queue
                    call = function(...)
                        queuePos = queuePos + 1

                        if queue[queuePos].callback then
                            queue[queuePos].callback(...)
                        end

                        -- Base case, end of the queue
                        if queuePos + 1 > #queue then
                            if onFinished then
                                onFinished()
                            end -- All queries have finished

                            return
                        end

                        -- Recursion
                        local nextQuery = queue[queuePos + 1]
                        query(nextQuery.query, call, nextQuery.onError)
                    end

                    query(queue[1].query, call, queue[1].onError)
                end

                function queueQuery(sqlText, callback, errorCallback)
                    if CONNECTED_TO_MYSQL then
                        table.insert(queuedQueries, {
                            query = sqlText,
                            callback = callback,
                            onError = errorCallback
                        })

                        return
                    end

                    -- SQLite is instantaneous, simply running the query is equal to queueing it
                    query(sqlText, callback, errorCallback)
                end

                local function msOOQuery(sqlText, callback, errorCallback, queryValue)
                    local query = databaseObject:query(sqlText)
                    local data

                    query.onData = function(Q, D)
                        data = data or {}
                        data[#data + 1] = D
                    end

                    query.onError = function(Q, E)
                        if databaseObject:status() == mysqlOO.DATABASE_NOT_CONNECTED then
                            table.insert(cachedQueries, {sqlText, callback, queryValue})
                            -- Immediately try reconnecting
                            msOOConnect(MySQLite_config.Host, MySQLite_config.Username, MySQLite_config.Password, MySQLite_config.Database_name, MySQLite_config.Database_port)

                            return
                        end

                        local supp = errorCallback and errorCallback(E, sqlText)

                        if not supp then
                            error(E .. " (" .. sqlText .. ")")
                        end
                    end

                    query.onSuccess = function()
                        local res = queryValue and data and data[1] and table.GetFirstValue(data[1]) or not queryValue and data or nil

                        if callback then
                            callback(res, query:lastInsert())
                        end
                    end

                    query:start()
                end

                local function tmsqlQuery(sqlText, callback, errorCallback, queryValue)
                    local call = function(res)
                        res = res[1] -- For now only support one result set

                        if not res.status then
                            local supp = errorCallback and errorCallback(res.error, sqlText)

                            if not supp then
                                error(res.error .. " (" .. sqlText .. ")")
                            end

                            return
                        end

                        if not res.data or #res.data == 0 then
                            res.data = nil
                        end -- compatibility with other backends

                        if queryValue and callback then
                            return callback(res.data and res.data[1] and table.GetFirstValue(res.data[1]) or nil)
                        end

                        if callback then
                            callback(res.data, res.lastid)
                        end
                    end

                    databaseObject:Query(sqlText, call)
                end

                local function SQLiteQuery(sqlText, callback, errorCallback, queryValue)
                    local lastError = sql.LastError()
                    local Result = queryValue and sql.QueryValue(sqlText) or sql.Query(sqlText)

                    if sql.LastError() and sql.LastError() ~= lastError then
                        local err = sql.LastError()
                        local supp = errorCallback and errorCallback(err, sqlText)

                        if not supp then
                            error(err .. " (" .. sqlText .. ")")
                        end

                        return
                    end

                    if callback then
                        callback(Result)
                    end

                    return Result
                end

                function query(sqlText, callback, errorCallback)
                    local qFunc = (CONNECTED_TO_MYSQL and mysqlOO and msOOQuery or TMySQL and tmsqlQuery) or SQLiteQuery

                    return qFunc(sqlText, callback, errorCallback, false)
                end

                function queryValue(sqlText, callback, errorCallback)
                    local qFunc = (CONNECTED_TO_MYSQL and mysqlOO and msOOQuery or TMySQL and tmsqlQuery) or SQLiteQuery

                    return qFunc(sqlText, callback, errorCallback, true)
                end

                local function onConnected()
                    CONNECTED_TO_MYSQL = true

                    -- Run the queries that were called before the connection was made
                    for k, v in pairs(cachedQueries or {}) do
                        cachedQueries[k] = nil

                        if v[3] then
                            queryValue(v[1], v[2])
                        else
                            query(v[1], v[2])
                        end
                    end

                    cachedQueries = {}
                    hook.Run("DatabaseInitialized")
                end

                msOOConnect = function(host, username, password, database_name, database_port)
                    databaseObject = mysqlOO.connect(host, username, password, database_name, database_port)

                    if timer.Exists("darkrp_check_mysql_status") then
                        timer.Remove("darkrp_check_mysql_status")
                    end

                    databaseObject.onConnectionFailed = function(_, msg)
                        timer.Simple(5, function()
                            msOOConnect(MySQLite_config.Host, MySQLite_config.Username, MySQLite_config.Password, MySQLite_config.Database_name, MySQLite_config.Database_port)
                        end)

                        error("Connection failed! " .. tostring(msg) .. "\nTrying again in 5 seconds.")
                    end

                    databaseObject.onConnected = onConnected
                    databaseObject:connect()
                end

                local function tmsqlConnect(host, username, password, database_name, database_port)
                    local db, err = TMySQL.initialize(host, username, password, database_name, database_port)

                    if err then
                        error("Connection failed! " .. err .. "\n")
                    end

                    databaseObject = db
                    onConnected()
                end

                function connectToMySQL(host, username, password, database_name, database_port)
                    database_port = database_port or 3306
                    local func = mysqlOO and msOOConnect or TMySQL and tmsqlConnect or function() end
                    func(host, username, password, database_name, database_port)
                end

                function SQLStr(str)
                    local escape = not CONNECTED_TO_MYSQL and sql.SQLStr or mysqlOO and function(str) return "\"" .. databaseObject:escape(tostring(str)) .. "\"" end or TMySQL and function(str) return "\"" .. databaseObject:Escape(tostring(str)) .. "\"" end

                    return escape(str)
                end

                function tableExists(tbl, callback, errorCallback)
                    if not CONNECTED_TO_MYSQL then
                        local exists = sql.TableExists(tbl)
                        callback(exists)

                        return exists
                    end

                    queryValue(string.format("SHOW TABLES LIKE %s", SQLStr(tbl)), function(v)
                        callback(v ~= nil)
                    end, errorCallback)
                end
            end
        end
    end
else
    return
end