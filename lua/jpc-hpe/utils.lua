-- Utility functions for the jpc-hpe plugin
local M = {}

-- Simple utility function to print a formatted message
function M.print_message(msg, level)
  level = level or "info"
  local prefix = "[jpc-hpe] "
  
  if level == "error" then
    vim.api.nvim_err_writeln(prefix .. msg)
  elseif level == "warn" then
    vim.api.nvim_echo({{prefix .. msg, "WarningMsg"}}, true, {})
  else
    vim.api.nvim_echo({{prefix .. msg, "None"}}, false, {})
  end
end

-- Validate configuration options
function M.validate_config(config)
  -- Add validation logic here
  if type(config) ~= "table" then
    M.print_message("Config must be a table", "error")
    return false
  end
  
  return true
end

-- Return the module
return M
