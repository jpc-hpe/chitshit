-- Commands implementation for jpc-hpe plugin
local utils = require('jpc-hpe.utils')
local M = {}

-- Example command implementation
function M.hello_command()
  utils.print_message("Hello from jpc-hpe plugin command!")
end

-- Add more commands as needed

-- Return the module
return M
