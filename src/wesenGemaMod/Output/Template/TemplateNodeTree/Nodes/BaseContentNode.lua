---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseTemplateNode = require("Output/Template/TemplateNodeTree/Nodes/BaseTemplateNode")

---
-- Base class for nodes that contain output content.
--
-- @type BaseContentNode
--
local BaseContentNode = setmetatable({}, {__index = BaseTemplateNode})


---
-- BaseContentNode constructor.
--
-- @treturn BaseContentNode The BaseContentNode instance
--
function BaseContentNode:__construct()

  local instance = BaseTemplateNode()
  setmetatable(instance, {__index = BaseContentNode})

  return instance

end

getmetatable(BaseContentNode).__call = BaseContentNode.__construct


-- Public Methods

---
-- Generates and returns a table from this node and its inner contents.
--
-- @treturn table The table
--
function BaseContentNode:toTable()
  return self:mergeInnerContents("table")
end

---
-- Generates and returns a string from this node and its inner contents.
--
-- @treturn string The string
--
function BaseContentNode:toString()
  return self:mergeInnerContents("string")
end


---
-- Generates and returns a table or string from the inner text and tags.
--
-- @tparam string _mergeType The merge type ("string" or "table")
--
-- @treturn string|table The merged inner contents
--
function BaseContentNode:mergeInnerContents(_mergeType)

  local innerTextIndex = 1
  local innerNodeIndex = 1

  local mergedContents
  if (_mergeType == "string") then
    mergedContents = ""
  elseif (_mergeType == "table") then
    mergedContents = {}
  end

  for _, innerContent in ipairs(self.innerContents) do

    if (innerContent == "text") then

      local innerText = self.innerTexts[innerTextIndex]
      if (#innerText > 0) then

        if (_mergeType == "string") then
          mergedContents = mergedContents .. innerText
        elseif (_mergeType == "table") then
          table.insert(mergedContents, innerText)
        end

      end

      innerTextIndex = innerTextIndex + 1

    else
      local innerNode = self.innerNodes[innerNodeIndex]

      if (_mergeType == "string") then
        mergedContents = mergedContents .. innerNode:toString()
      elseif (_mergeType == "table") then
        table.insert(mergedContents, innerNode:toTable())
      end

      innerNodeIndex = innerNodeIndex + 1
    end

  end

  return mergedContents

end


return BaseContentNode
