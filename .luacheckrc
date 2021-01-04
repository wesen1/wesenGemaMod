-- Files
include_files = { "src", "tests/wesenGemaMod", "test/*.lua" };
exclude_files = { "src/config", "src/external" }

-- Don't warn when function arguments are not used (because of arguments in event handlers)
unused_args = false;

-- Don't warn when class methods don't use self
self = false;

-- The list of global variables that are provided by the lua server and are used in this project
globals = {

  -- Plugin information
  "PLUGIN_NAME",
  "PLUGIN_AUTHOR",
  "PLUGIN_VERSION",
};
