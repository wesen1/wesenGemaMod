---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- LDoc configuration.
--

title = "wesenGemaMod documentation";
description = "Gema mod for AssaultCube Lua servers";
project = "wesenGemaMod";

file = {
  "../../src/wesenGemaMod",
  --"../../tests/wesenGemaMod"
}
package = "wesenGemaMod";
dir = "docs";

wrap = true;

custom_see_handler(
  "^(https?://([^/]+).+)$",
  function (_fullUrl, _baseUrl)
    return _baseUrl, _fullUrl
  end
)
