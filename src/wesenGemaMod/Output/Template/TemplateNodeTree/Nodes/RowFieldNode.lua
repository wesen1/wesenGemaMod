---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseContentNode = require("Output/Template/TemplateNodeTree/Nodes/BaseContentNode")

---
-- Represents a row field.
--
-- @type RowFieldNode
--
local RowFieldNode = setmetatable({}, {__index = BaseContentNode})


---
-- The name of this node type
--
-- @tfield string name
--
RowFieldNode.name = "row-field"

---
-- Static list of tag names that close this node when they occur during the tree parsing
--
-- @tfield string[] closedByTagNames
--
RowFieldNode.closedByTagNames = { "row", "custom-field", "custom-field-end", "row-field"}


---
-- RowFieldNode constructor.
--
-- @treturn RowFieldNode The RowFieldNode instance
--
function RowFieldNode:__construct()

  local instance = BaseContentNode()
  setmetatable(instance, {__index = RowFieldNode})

  return instance

end

getmetatable(RowFieldNode).__call = RowFieldNode.__construct


-- Public Methods

---
-- Generates and returns a table from this node and its inner contents.
--
-- @treturn mixed The table representation of this node
--
function RowFieldNode:toTable()
  return table.concat(self.innerTexts)
end


return RowFieldNode
