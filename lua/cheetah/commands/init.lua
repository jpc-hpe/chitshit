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
  local keymaps = vim.api.nvim_get_keymap("a") -- Get keymaps for all modes

  for _, map in ipairs(keymaps) do
    if map.callback and type(map.callback) == "function" then
      local info = debug.getinfo(map.callback, "S")
      if info then
        local funcName = debug.getinfo(map.callback, "n").name
        map.decoded_callback = string.format("function defined in %s at line %s, name: %s", 
          info.short_src or "unknown source", 
          info.linedefined or "unknown", 
          funcName or "unknown")
      else
        map.decoded_callback = string.format("  %s: function: %s", key, tostring(value))
      end
    end
  end
  for _, map in ipairs(keymaps) do
    print("Keymap:")
    for key, value in pairs(map) do
      -- Skip printing lhsraw and lhsrawalt
      if key == "lhsraw" or key == "lhsrawalt" then
        -- Skip these fields
      else
        print(string.format("  %s: %s", key, tostring(value)))
      end
    end
    print("-------------------")
  end

-- Add more commands as needed
end

-- Return the module
return M
