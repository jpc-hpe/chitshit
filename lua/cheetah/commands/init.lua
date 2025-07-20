-- Commands implementation for cheetah plugin
local utils = require('cheetah.utils')
local M = {}

-- Example command implementation
function M.hello_command()
  utils.print_message("Hello from cheetah plugin command!")
end

-- Add more commands as needed

-- Return the module
return M
