---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local StaticString = require "Output.StaticString"

---
-- Stores the configuration for a single command argument.
--
-- @type CommandArgument
--
local CommandArgument = Object:extend()

---
-- The full name of the argument
--
-- @tfield string name
--
CommandArgument.name = nil

---
-- The short name of the argument
-- This will be the same as the full name if no short name is defined
--
-- @tfield string shortName
--
CommandArgument.shortName = nil

---
-- Defines whether this argument is optional or required
--
-- @tfield bool isOptional
--
CommandArgument.isOptional = nil

---
-- The description of the argument that will be shown in the help text of command
--
-- @tfield string description
--
CommandArgument.description = nil

---
-- The type to which this arguments value shall be converted
-- Valid types are: integer, float, bool, string
--
-- @tfield string type
--
CommandArgument.type = nil


---
-- CommandArgument constructor.
--
-- @tparam string _name The name of the argument
-- @tparam bool _isOptional Defines whether the argument is optional or required
-- @tparam string _type The type to which this arguments value shall be converted (integer, float, bool, string)
-- @tparam string _shortName The short name of the argument (used in !cmds)
-- @tparam string _description The description of the argument
--
function CommandArgument:new(_name, _isOptional, _type, _shortName, _description)

  self.name = _name
  self.isOptional = (_isOptional == true)

  if (_type) then
    self.type = _type
  else
    self.type = "string"
  end

  if (_shortName) then
    self.shortName = _shortName
  else
    self.shortName = _name
  end

  if (_description) then
    self.description = _description
  else
    self.description = StaticString("defaultArgumentDescription"):getString()
  end

end


-- Getters and Setters

---
-- Returns the arguments full name.
--
-- @treturn string The arguments full name
--
function CommandArgument:getName()
  return self.name
end

---
-- Returns the arguments short name.
--
-- @treturn string The arguments short name
--
function CommandArgument:getShortName()
  return self.shortName
end

---
-- Returns the arguments type.
--
-- @treturn string The arguments type
--
function CommandArgument:getType()
  return self.type
end

---
-- Returns whether the argument is required or optional.
--
-- @treturn bool True if the argument is optional, false if it is required
--
function CommandArgument:getIsOptional()
  return self.isOptional
end

---
-- Returns the arguments description.
--
-- @treturn string The arguments description
--
function CommandArgument:getDescription()
  return self.description
end


return CommandArgument
