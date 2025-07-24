-- Commands implementation for cheetah plugin
local utils = require('cheetah.utils')
local M = {}

-- Example command implementation
function M.hello_command()
  print("Just using print")
  utils.print_message("Hello cheetah!") -- same as info level
  -- utils.print_message("warning from cheetah plugin command!", "warn")
  -- utils.print_message("error from cheetah plugin command!", "error")
  -- utils.print_message("info from cheetah plugin command!", "info")
  get_keymaps()

  
end

function get_keymaps()
  local keymaps = vim.api.nvim_get_keymap() -- Get keymaps for all modes
  for _, map in ipairs(keymaps) do
    print("Keymap:")
    for key, value in pairs(map) do
      print(string.format("  %s: %s", key, value))
    end
    print("-------------------")
  end
end

-- Add more commands as needed

-- Return the module
return M
