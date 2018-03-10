---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--
local luasql = require "luasql.mysql";

---
-- @type DataBase Handles database access.
-- The class only works when the database server is on the same machine like the assaultcube server
--
local DataBase = {};

---
-- The database user
--
-- @tfield string user
--
DataBase.user = "";

---
-- The database users password
--
-- @tfield string password
--
DataBase.password = "";

---
-- The database name
--
-- @tfield string dataBaseName
--
DataBase.dataBaseName = "";


---
-- DataBase constructor.
--
-- @tparam string _user The username for the lua server
-- @tparam string _password The password for the user
-- @tparam string _dataBaseName The name of the database for the gema mod
--
-- @treturn DataBase The DataBase instance
--
function DataBase:__construct(_user, _password, _dataBaseName)

  local instance = {};
  setmetatable(instance, {__index = DataBase});

  instance.user = _user;
  instance.password = _password;
  instance.dataBaseName = _dataBaseName;

  return instance;

end


-- Getters and setters

---
-- Returns the database user name.
--
-- @treturn string The database user name
--
function DataBase:getUser()
  return self.user;
end

---
-- Sets the database user name.
--
-- @tparam string _user The database user name
--
function DataBase:setUser(_user)
  self.user = _user;
end

---
-- Returns the database users password.
--
-- @treturn string The database users password
--
function DataBase:getPassword()
  return self.password;
end

---
-- Sets the database users password.
--
-- @tparam string _password The database users password
--
function DataBase:setPassword(_password)
  self.password = _password;
end

---
-- Returns the database name.
--
-- @treturn string The database name
--
function DataBase:getDataBaseName()
  return self.dataBaseName;
end

---
-- Sets the database name.
--
-- @tparam string _dataBaseName The database name
--
function DataBase:setDataBaseName(_dataBaseName)
  self.dataBaseName = _dataBaseName;
end


-- Class Methods

---
-- Executes a single query.
--
-- @tparam string _sql The sql query
-- @tparam bool _expectsResult True: The result from the query will be returned as a table
--                             False: No result will be returned
--
-- @treturn table|nil The result or nil
--
function DataBase:query(_sql, _expectsResult)

  local env = luasql.mysql();
  local conn = env:connect(self.dataBaseName, self.user, self.password);
  local cur = conn:execute(_sql);
  local rows = {};

  if (_expectsResult == true) then

    local counter = 0;

    while (#rows == counter) do
      table.insert(rows, cur:fetch ({}, "a"));
      counter = counter + 1;
    end

    cur:close();

  end

  conn:close();
  env:close();

  return rows;

end

---
-- Sanitizes sql string values.
-- Use this function on everything that can be manipulated by players (mapnames, playernames, passwords, etc.)
-- before adding it to any sql query
--
-- @tparam string _sqlStringValue The value which shall be sanitized
--
-- @treturn string The sanitized value
--
function DataBase:sanitize(_sqlStringValue)

  local env = luasql.mysql();
  local conn = env:connect(self.dataBaseName, self.user, self.password);

  local sanitizedValue = conn:escape(_sqlStringValue);

  conn:close();
  env:close();

  return sanitizedValue;

end


return DataBase;
