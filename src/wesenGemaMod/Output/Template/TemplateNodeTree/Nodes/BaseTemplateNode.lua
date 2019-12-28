---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TableUtils = require("Util/TableUtils")

---
-- Represents a node in a TemplateNodeTree.
--
-- @type BaseTemplateNode
--
local BaseTemplateNode = setmetatable({}, {})


---
-- The parent node
-- May be nil if this node is the root node
--
-- @tfield BaseTemplateNode parentNode
--
BaseTemplateNode.parentNode = nil

---
-- Stores the strings inside this node that are not inside sub nodes
--
-- @tfield string[] innerTexts
--
BaseTemplateNode.innerTexts = {}

---
-- Stores the child nodes of this node
--
-- @tfield BaseTemplateNode[] innerNodes
--
BaseTemplateNode.innerNodes = {}

---
-- Stores the order in which inner texts and nodes were added
-- The values inside this list are either "text" or "node"
--
-- @tfield string[] innerContents
--
BaseTemplateNode.innerContents = {}


---
-- The name of this node type
--
-- @tfield string name
--
BaseTemplateNode.name = ""

---
-- Static list of tag names that open a node of this type when they occur during the tree parsing
--
-- @tfield string[] openedByTagNames
--
BaseTemplateNode.openedByTagNames = {}

---
-- Static list of tag names that close this node when they occur during the tree parsing
--
-- @tfield string[] closedByTagNames
--
BaseTemplateNode.closedByTagNames = {}


---
-- BaseTemplateNode constructor.
--
-- @treturn BaseTemplateNode The BaseTemplateNode instance
--
function BaseTemplateNode:__construct()

  local instance = setmetatable({}, {__index = BaseTemplateNode})

  instance.innerTexts = {}
  instance.innerNodes = {}
  instance.innerContents = {}

  return instance

end

getmetatable(BaseTemplateNode).__call = BaseTemplateNode.__construct


-- Getters and Setters

---
-- Returns the name of this node type.
--
-- @treturn string The name
--
function BaseTemplateNode:getName()
  return self.name
end

---
-- Returns the parent node.
--
-- @treturn BaseTemplateNode The parent node
--
function BaseTemplateNode:getParentNode()
  return self.parentNode
end

---
-- Sets the parent node.
--
-- @tparam BaseTemplateNode _parentNode The parent node
--
function BaseTemplateNode:setParentNode(_parentNode)
  self.parentNode = _parentNode
end


-- Public Methods

---
-- Adds an inner text to this node.
--
-- @tparam string _text The inner text
--
-- @treturn BaseTemplateNode The template node to which the inner text was added
--
function BaseTemplateNode:addInnerText(_text)
  table.insert(self.innerTexts, _text)
  table.insert(self.innerContents, "text")

  return self
end

---
-- Adds an inner node to this node.
--
-- @tparam BaseTemplateNode _node The node
--
-- @treturn BaseTemplateNode The template node to which the inner node was added
--
function BaseTemplateNode:addInnerNode(_node)

  _node:setParentNode(self)
  table.insert(self.innerNodes, _node)
  table.insert(self.innerContents, "node")

  return self

end

---
-- Returns whether this node is closed by a specific tag.
--
-- @tparam TemplateTag _tag The tag
--
-- @treturn bool True if this node is closed by the tag, false otherwise
--
function BaseTemplateNode:isClosedByTag(_tag)
  return (TableUtils.tableHasValue(self.closedByTagNames, _tag:getName()))
end

---
-- Returns whether this node is opened by a specific tag.
--
-- @tparam TemplateTag _tag The tag
--
-- @treturn bool True if this node is opened by the tag, false otherwise
--
function BaseTemplateNode:isOpenedByTag(_tag)
  return (TableUtils.tableHasValue(self.openedByTagNames, _tag:getName()))
end

---
-- Returns a list of inner nodes with a specific name.
--
-- @tparam string _nodeName The node name
--
-- @treturn BaseTemplateNode[] The list of inner nodes with that name
--
function BaseTemplateNode:find(_nodeName)

  local matchingNodes = {}
  for _, innerNode in ipairs(self.innerNodes) do

    if (innerNode:getName() == _nodeName) then
      table.insert(matchingNodes, innerNode)
    end

  end

  return matchingNodes

end


-- Protected Methods

---
-- Generates and returns a table from this node and its inner contents.
--
-- @treturn mixed The table representation of this node
--
function BaseTemplateNode:toTable()
  return {}
end

---
-- Generates and returns a string from this node and its inner contents.
--
-- @treturn string The string
--
function BaseTemplateNode:toString()
  return ""
end


return BaseTemplateNode
