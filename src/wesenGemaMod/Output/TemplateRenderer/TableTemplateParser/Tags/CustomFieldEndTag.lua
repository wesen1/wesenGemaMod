---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/BaseTag");
local RowFieldTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/RowFieldTag");
local RowTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/RowTag");
local CustomFieldTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/CustomFieldTag");

---
-- Represents a closing custom field tag.
--
-- @type CustomFieldEndTag
--
local CustomFieldEndTag = setmetatable({}, {__index = BaseTag});


---
-- The list of tag types that are closed by this tag
--
-- @tfield BaseTag[] closeTagTypes
--
CustomFieldEndTag.closeTagTypes = {RowFieldTag, RowTag, CustomFieldTag};
-- @todo: closeTagTypes should automatically inherit the sub close tag types (e.g. here from RowTag)

---
-- CustomFieldEndTag constructor.
--
-- @treturn CustomFieldEndTag The CustomFieldEndTag instance
--
function CustomFieldEndTag:__construct(_tagString)

  local instance = BaseTag:__construct();
  setmetatable(instance, {__index = CustomFieldEndTag});

  return instance;

end

getmetatable(CustomFieldEndTag).__call = CustomFieldEndTag.__construct;


---
-- Returns the tag instance that will be inserted into the tag tree.
-- The custom field end tag is just the counter part to the custom field opening tag, that's why it must
-- return a normal row field tag as open tag.
--
-- @treturn RowFieldTag The tag instance that will be inserted into the tag tree
--
function CustomFieldEndTag:getTagOpenInstance()
  return RowFieldTag();
end


-- Protected Methods

---
-- Returns the table representation for this tag.
-- CustomFieldEndTags never contain any inner contents.
--
-- @treturn nil Nil because this tag type has no inner contents
--
function CustomFieldEndTag:generateTable()
  return nil;
end


return CustomFieldEndTag;
