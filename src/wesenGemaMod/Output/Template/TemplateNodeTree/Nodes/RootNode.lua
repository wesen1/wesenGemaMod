---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseTemplateNode = require("Output/Template/TemplateNodeTree/Nodes/BaseTemplateNode")
local ContentNode = require("Output/Template/TemplateNodeTree/Nodes/ContentNode")

---
-- Represents the root of a TemplateNodeTree.
--
-- @type RootNode
--
local RootNode = setmetatable({}, {__index = BaseTemplateNode})


---
-- RootNode constructor.
--
-- @treturn RootNode The RootNode instance
--
function RootNode:__construct()

  local instance = BaseTemplateNode()
  setmetatable(instance, {__index = RootNode})

  return instance

end

getmetatable(RootNode).__call = RootNode.__construct


-- Public Methods

---
-- Adds an inner text to this node.
--
-- @tparam string _text The inner text
--
-- @treturn BaseTemplateNode The template node to which the inner text was added
--
function RootNode:addInnerText(_text)
  local contentNode = ContentNode()
  self:addInnerNode(contentNode)

  return contentNode:addInnerText(_text)
end

---
-- Adds an inner node to this node.
--
-- @tparam BaseTemplateNode _node The node
--
-- @treturn BaseTemplateNode The template node to which the inner node was added
--
function RootNode:addInnerNode(_node)

  if (_node:getName() == "config" or _node:getName() == "content") then
    return BaseTemplateNode.addInnerNode(self, _node)
  else

    local contentNode = ContentNode(self)
    BaseTemplateNode.addInnerNode(self, contentNode)

    return contentNode:addInnerNode(_node)

  end

end


return RootNode
