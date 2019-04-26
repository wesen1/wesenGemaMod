---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseContentNode = require("Output/Template/TemplateNodeTree/Nodes/BaseContentNode")
local RowFieldNode = require("Output/Template/TemplateNodeTree/Nodes/RowFieldNode")

---
-- Represents a row.
--
-- @type RowNode
--
local RowNode = setmetatable({}, {__index = BaseContentNode})


---
-- The name of this node type
--
-- @tfield string name
--
RowNode.name = "row"

---
-- Static list of tag names that close this node when they occur during the tree parsing
--
-- @tfield string[] closedByTagNames
--
RowNode.closedByTagNames = { "row", "custom-field-end" }


---
-- RowNode constructor.
--
-- @treturn RowNode The RowNode instance
--
function RowNode:__construct()

  local instance = BaseContentNode()
  setmetatable(instance, {__index = RowNode})

  return instance

end

getmetatable(RowNode).__call = RowNode.__construct


-- Public Methods

---
-- Adds an inner text to this node.
--
-- @tparam string _text The inner text
--
-- @treturn BaseTemplateNode The template node to which the inner text was added
--
function RowNode:addInnerText(_text)
  local rowFieldNode = RowFieldNode()
  BaseContentNode.addInnerNode(self, rowFieldNode)

  return rowFieldNode:addInnerText(_text)
end


return RowNode
