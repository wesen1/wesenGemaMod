---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Handles printing of arguments.
--
-- @type ArgumentPrinter
--
local ArgumentPrinter = setmetatable({}, {});


---
-- The output
--
-- @tfield Output output
--
ArgumentPrinter.output = nil;


---
-- ArgumentPrinter constructor.
--
-- @tparam Output _output The output
--
-- @treturn ArgumentPrinter The ArgumentPrinter instance
--
function ArgumentPrinter:__construct(_output)

  local instance = setmetatable({}, {__index = ArgumentPrinter});

  instance.output = _output;

  return instance;

end

getmetatable(ArgumentPrinter).__call = ArgumentPrinter.__construct;


-- Public Methods

---
-- Returns the short argument string.
--
-- @tparam CommandArgument _argument The argument
--
-- @treturn string The short argument string
--
function ArgumentPrinter:getShortArgumentString(_argument)
  return self:getArgumentColor(_argument) .. "<" .. _argument:getShortName() .. ">";
end

---
-- Returns the full argument string.
--
-- @tparam CommandArgument _argument The argument
--
-- @treturn string The full argument string
--
function ArgumentPrinter:getFullArgumentString(_argument)
  return self:getArgumentColor(_argument) .. "<" .. _argument:getName() .. ">";
end


-- Private Methods

---
-- Returns the argument output color.
--
-- @tparam CommandArgument _argument The argument
--
-- @treturn string The argument output color
--
function ArgumentPrinter:getArgumentColor(_argument)

  if (_argument:getIsOptional()) then
    return self.output:getColor("optionalArgument");
  else
    return self.output:getColor("requiredArgument");
  end

end


return ArgumentPrinter;
