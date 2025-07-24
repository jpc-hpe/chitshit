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
    print("Keymap:")
    for key, value in pairs(map) do
      if key == "callback" and type(value) == "function" then
        -- Try to get more info about the function
        local info = debug.getinfo(value, "S")
        if info then
          print(string.format("  %s: function defined in %s at line %s", 
            key, info.short_src or "unknown source", info.linedefined or "unknown"))
          
          -- Try to get the function name
          local funcName = debug.getinfo(value, "n").name
          if funcName then
            print(string.format("  function name: %s", funcName))
          end
        else
          print(string.format("  %s: function: %s", key, tostring(value)))
        end
      else
        print(string.format("  %s: %s", key, tostring(value)))
      end
    end
    print("-------------------")
  end
end

-- Add more commands as needed

-- Return the module
return M
