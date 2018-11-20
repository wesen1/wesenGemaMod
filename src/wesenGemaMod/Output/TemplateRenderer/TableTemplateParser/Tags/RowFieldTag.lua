---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/BaseTag");

---
-- Represents a row field.
--
-- @type RowFieldTag
--
local RowFieldTag = setmetatable({}, {__index = BaseTag});


---
-- The list of tag types that are closed by this tag
--
-- @tfield BaseTag[] closeTagTypes
--
RowFieldTag.closeTagTypes = {RowFieldTag};


---
-- RowFieldTag constructor.
--
-- @treturn RowFieldTag The RowFieldTag instance
--
function RowFieldTag:__construct()

  local instance = BaseTag:__construct();
  setmetatable(instance, {__index = RowFieldTag});

  return instance;

end

getmetatable(RowFieldTag).__call = RowFieldTag.__construct;


---
-- Returns the table representation for this row field tag.
-- Row fields never contain inner tags and are closed on encountering any other tag.
--
-- @treturn string|nil The table representation for this row field tag or nil if this row field is empty
--
function RowFieldTag:generateTable()

  if (self.innerTexts and self.innerTexts[1] ~= "") then
    return self.innerTexts[1];
  else
    return nil;
  end

end


return RowFieldTag;
