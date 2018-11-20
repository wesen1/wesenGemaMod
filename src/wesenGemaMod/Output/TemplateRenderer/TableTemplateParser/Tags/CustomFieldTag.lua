---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local RootTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/RootTag");
local RowFieldTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/RowFieldTag");

---
-- Represents a custom field.
-- A custom field is like a inner root tag, tags inside a custom field tag cannot interact with tags that
-- are outside of the custom field
--
-- @type CustomFieldTag
--
local CustomFieldTag = setmetatable({}, {__index = RootTag});


---
-- The list of tag types that are closed by this tag
--
-- @tfield BaseTag[] closeTagTypes
--
CustomFieldTag.closeTagTypes = {RowFieldTag};


---
-- CustomFieldTag constructor.
--
-- @treturn CustomFieldTag The CustomFieldTag instance
--
function CustomFieldTag:__construct()

  local instance = RootTag:__construct();
  setmetatable(instance, {__index = CustomFieldTag});

  return instance;

end

getmetatable(CustomFieldTag).__call = CustomFieldTag.__construct;


return CustomFieldTag;
