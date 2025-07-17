-- This file ensures the plugin is loaded properly
if vim.fn.has('nvim-0.7') == 0 then
  vim.api.nvim_err_writeln("jpc-hpe requires at least Neovim 0.7")
  return
end

-- Prevent loading the plugin multiple times
if vim.g.loaded_jpc_hpe == 1 then
  return
end
vim.g.loaded_jpc_hpe = 1

-- Define user commands if needed
vim.api.nvim_create_user_command('JpcHpeHello', function()
  require('jpc-hpe').hello_world()
end, {
  desc = "Say hello from jpc-hpe plugin"
})

-- The plugin will need to be explicitly set up by the user in their config:
-- require('jpc-hpe').setup({})
