---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseTemplateNode = require("Output/Template/TemplateNodeTree/Nodes/BaseTemplateNode")
local StringUtils = require("Util/StringUtils")

---
-- Represents the config section for the template.
--
-- @type ConfigNode
--
local ConfigNode = setmetatable({}, {__index = BaseTemplateNode})


---
-- The name of this node type
--
-- @tfield string name
--
ConfigNode.name = "config"

---
-- Static list of tag names that open a node of this type when they occur during the tree parsing
--
-- @tfield string[] openedByTagNames
--
ConfigNode.openedByTagNames = { "config" }

---
-- Static list of tag names that close this node when they occur during the tree parsing
--
-- @tfield string[] closedByTagNames
--
ConfigNode.closedByTagNames = { "end-config" }


---
-- ConfigNode constructor.
--
-- @treturn ConfigNode The ConfigNode instance
--
function ConfigNode:__construct()

  local instance = BaseTemplateNode()
  setmetatable(instance, {__index = ConfigNode})

  return instance

end

getmetatable(ConfigNode).__call = ConfigNode.__construct


-- Public Methods

---
-- Generates and returns a table from this node and its inner contents.
--
-- @treturn mixed The table representation of this node
--
function ConfigNode:toTable()

  local getConfigurationFunction = loadstring("return " .. self:getTableStringFromInnerTexts())
  if (getConfigurationFunction) then
    return getConfigurationFunction()
  else
    return {}
  end

end


-- Private Methods

---
-- Returns a string that defines a lua table from the inner texts of this node.
--
-- @treturn string The table string
--
function ConfigNode:getTableStringFromInnerTexts()

  -- Convert the configuration string to a lua table
  local configurationValues = table.concat(self.innerTexts)

  local configurationTableFields = ""
  local isFirstValue = true
  for _, configurationValue in ipairs(StringUtils:split(configurationValues, ";")) do

    if (isFirstValue) then
      isFirstValue = false
    else
      configurationTableFields = configurationTableFields .. ","
    end

    configurationTableFields = configurationTableFields .. configurationValue
  end

  return "{" .. configurationTableFields .. "}"

end


return ConfigNode
