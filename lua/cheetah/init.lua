-- Main module for cheetah Neovim plugin
local M = {}
local utils = require('cheetah.utils')
local commands = require('cheetah.commands')

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
    -- Generate helptags automatically when the plugin is setup
    local doc_path = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h:h') .. '/doc'
    
    -- Debug info before generating helptags
    utils.print_message("DEBUG: Attempting to generate helptags for path: " .. doc_path, "warn")
    utils.print_message("DEBUG: Directory exists: " .. tostring(vim.fn.isdirectory(doc_path) == 1), "warn")
    
    if vim.fn.isdirectory(doc_path) == 1 then
      utils.print_message("DEBUG: Running helptags command now...", "warn")
      vim.cmd('silent! helptags ' .. doc_path)
      utils.print_message("DEBUG: Helptags command completed", "warn")
    else
      utils.print_message("DEBUG: Doc directory not found, skipping helptags", "warn")
    end
    
    -- Add initialization code here
    utils.print_message("cheetah plugin initialized")
  end
end

-- Add your plugin functions here
function M.hello_world()
  commands.hello_command()
end

-- Return the module
return M
