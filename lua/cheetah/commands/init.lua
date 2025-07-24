-- Commands implementation for cheetah plugin
local utils = require('cheetah.utils')
local M = {}

-- Example command implementation
function M.hello_command()
  utils.print_message("Hello cheetah!") -- same as info level
  -- utils.print_message("warning from cheetah plugin command!", "warn")
  -- utils.print_message("error from cheetah plugin command!", "error")
  -- utils.print_message("info from cheetah plugin command!", "info")

  
end

-- Add more commands as needed

-- Return the module
return M
