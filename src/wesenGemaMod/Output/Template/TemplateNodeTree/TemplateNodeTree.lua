---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local RootNode = require("Output/Template/TemplateNodeTree/Nodes/RootNode")
local TagFinder = require("Output/Template/TemplateNodeTree/TagFinder/TagFinder")

---
-- Parses rendered template strings into a tree like structure of template nodes.
--
-- @type TemplateNodeTree
--
local TemplateNodeTree = setmetatable({}, {})


---
-- The tag finder
--
-- @tfield TagFinder tagFinder
--
TemplateNodeTree.tagFinder = nil

---
-- The list of available node types
--
-- @tfield BaseNode[] nodeTypes
--
TemplateNodeTree.nodeTypes = {
  require("Output/Template/TemplateNodeTree/Nodes/ConfigNode"),
  require("Output/Template/TemplateNodeTree/Nodes/ContentNode"),
  require("Output/Template/TemplateNodeTree/Nodes/CustomFieldNode"),
  require("Output/Template/TemplateNodeTree/Nodes/RootNode"),
  require("Output/Template/TemplateNodeTree/Nodes/RowFieldNode"),
  require("Output/Template/TemplateNodeTree/Nodes/RowNode")
}

---
-- The root node
--
-- @tfield RootNode rootNode
--
TemplateNodeTree.rootNode = nil


-- Parse loop variables

---
-- The target string of the current parse call
--
-- @tfield string targetString
--
TemplateNodeTree.targetString = nil

---
-- The current position inside the target string
--
-- @tfield int currentStringPosition
--
TemplateNodeTree.currentStringPosition = nil

---
-- The current open node
--
-- @tfield BaseTemplateNode currentNode
--
TemplateNodeTree.currentNode = nil


---
-- TemplateNodeTree constructor.
--
-- @treturn TemplateNodeTree The TemplateNodeTree instance
--
function TemplateNodeTree:__construct()

  local instance = setmetatable({}, {__index = TemplateNodeTree})
  instance.tagFinder = TagFinder()

  return instance

end

getmetatable(TemplateNodeTree).__call = TemplateNodeTree.__construct


-- Getters and Setters

---
-- Returns the root node.
--
-- @treturn RootNode The root node
--
function TemplateNodeTree:getRootNode()
  return self.rootNode
end


-- Public Methods

---
-- Parses a rendered text template into this tree.
--
-- @tparam string _renderedTemplateString The renderd template string
--
function TemplateNodeTree:parse(_renderedTemplateString)

  self.targetString = _renderedTemplateString
  self.currentStringPosition = 1

  self.rootNode = RootNode()
  self.currentNode = self.rootNode

  local nextTag = true
  while (nextTag) do

    -- Find the next tag
    nextTag = self.tagFinder:findNextTag(self.targetString, self.currentStringPosition)

    -- Add the text between the next tag and the current string position to the current node
    self:addInnerTextToCurrentNode(nextTag)

    if (nextTag) then
      self:parseTag(nextTag)
      self.currentStringPosition = nextTag:getEndPosition() + 1
    end

  end

end


-- Private Methods

---
-- Adds the inner text until the next tag start to the current node.
--
-- @tparam TemplateTag _nextTag The next tag or nil if there is no next tag
--
function TemplateNodeTree:addInnerTextToCurrentNode(_nextTag)

  local innerTextEndPosition
  if (_nextTag) then
    innerTextEndPosition = _nextTag:getStartPosition() - 1
    if (innerTextEndPosition < self.currentStringPosition) then
      return
    end

  else
    innerTextEndPosition = nil
    if (self.currentStringPosition == #self.targetString) then
      return
    end
  end

  local innerText = self.targetString:sub(self.currentStringPosition, innerTextEndPosition)
  if (innerText:match("^[ \t]*$")) then
    return
  end

  self.currentNode = self.currentNode:addInnerText(innerText)

end

---
-- Parses a template tag into this tree.
--
-- @tparam TemplateTag _tag The tag to parse
--
function TemplateNodeTree:parseTag(_tag)

  -- Close the corresponding nodes
  while (self.currentNode:isClosedByTag(_tag)) do
    self.currentNode = self.currentNode:getParentNode()
  end

  -- Open a new node when required
  for _, nodeType in ipairs(self.nodeTypes) do
    if (nodeType:isOpenedByTag(_tag)) then

      local node = nodeType(self.currentNode)

      self.currentNode:addInnerNode(node)
      self.currentNode = node

      break

    end
  end

end


return TemplateNodeTree
