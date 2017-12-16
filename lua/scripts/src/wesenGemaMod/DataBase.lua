---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
--
luasql = require "luasql.mysql";

---
-- Handles database access.
-- Only works when the database server is on the same machine like the assaultcube server
--
DataBase = {};

-- User for the database
DataBase.user = "";

-- Password for the user
DataBase.password = "";

-- Name of the database
DataBase.dbname = "";


--
-- DataBase constructor.
--
-- @param String _user      Username for the lua server
-- @param String _password  Password for the user
-- @param String _dbname    Name of the database for the lua server
--
function DataBase:__construct(_user, _password, _dbname)

  local instance = {};
  setmetatable(instance, {__index = DataBase});
  
  instance.user = _user;
  instance.password = _password;
  instance.dbname = _dbname;
  
  return instance;
  
end


-- Getters and Setters

--
-- Returns the database user.
--
-- @return String Database user
--
function DataBase:getUser()
  return self.user;
end

--
-- Sets the database user.
--
-- @param String _user  Database user
--
function DataBase:setUser(_user)
  self.user = _user;
end

--
-- Returns the database password.
--
-- @return String Database password
--
function DataBase:getPassword()
  return self.password;
end

--
-- Sets the database password.
--
-- @param String _password  Database password
--
function DataBase:setPassword(_password)
  self.password = _password;
end

--
-- Returns the database name.
--
-- @return String Database name
--
function DataBase:getDbName()
  return self.dbname;
end

--
-- Sets the database name.
--
-- @param String _dbname  Database name
--
function DataBase:setDbName(_dbname)
  self.dbname = _dbname;
end


--
-- Executes a single query.
--
-- @param string _sql           The sql query
-- @param bool _expectsResult   True: The result from the query will be returned as an array
--                              False: No result will be returned
--
function DataBase:query(_sql, _expectsResult)

  local env = luasql.mysql();
  local conn = env:connect(self.dbname, self.user, self.password);    
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

--
-- Sanitizes sql string values.
-- Hint: Use this function on everything that can be manipulated by players (mapnames, playernames, passwords, etc.)
--       before adding it to any sql query
--
-- @param string _sqlStringValue    The value which shall be sanitized
--
-- @return string   The sanitized value
--
function DataBase:sanitize(_sqlStringValue)

  local env = luasql.mysql();
  local conn = env:connect(self.dbname, self.user, self.password);
  
  local sanitizedValue = conn:escape(_sqlStringValue);
  
  conn:close();
  env:close();
  
  return sanitizedValue;

end

