-- Main module for jpc-hpe Neovim plugin
local M = {}
local utils = require('jpc-hpe.utils')
local commands = require('jpc-hpe.commands')

-- Default configuration
M.config = {
  enabled = true,
  -- Add more configuration options as needed
}

-- Setup function to be called by the user
function M.setup(opts)
  -- Merge user config with defaults
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)
  
  -- Validate configuration
  if not utils.validate_config(M.config) then
    return
  end
  
  -- Initialize the plugin
  if M.config.enabled then
    -- Add initialization code here
    utils.print_message("jpc-hpe plugin initialized")
  end
end

-- Add your plugin functions here
function M.hello_world()
  commands.hello_command()
end

-- Return the module
return M
