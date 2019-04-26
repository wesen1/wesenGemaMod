---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ContentNode = require("Output/Template/TemplateNodeTree/Nodes/ContentNode")

---
-- Represents a custom field.
-- A custom field is a field that contains a sub table
--
-- @type CustomFieldNode
--
local CustomFieldNode = setmetatable({}, {__index = ContentNode})


---
-- The name of this node type
--
-- @tfield string name
--
CustomFieldNode.name = "custom-field"

---
-- Static list of tag names that open a node of this type when they occur during the tree parsing
--
-- @tfield string[] openedByTagNames
--
CustomFieldNode.openedByTagNames = { "custom-field" }

---
-- Static list of tag names that close this node when they occur during the tree parsing
--
-- @tfield string[] closedByTagNames
--
CustomFieldNode.closedByTagNames = { "end-custom-field" }


---
-- CustomFieldNode constructor.
--
-- @treturn CustomFieldNode The CustomFieldNode instance
--
function CustomFieldNode:__construct()

  local instance = ContentNode()
  setmetatable(instance, {__index = CustomFieldNode})

  return instance

end

getmetatable(CustomFieldNode).__call = CustomFieldNode.__construct


return CustomFieldNode
