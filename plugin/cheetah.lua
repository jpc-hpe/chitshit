-- This file ensures the plugin is loaded properly
if vim.fn.has('nvim-0.7') == 0 then
  vim.api.nvim_err_writeln("cheetah requires at least Neovim 0.7")
  return
end

-- Prevent loading the plugin multiple times
if vim.g.loaded_cheetah == 1 then
  return
end
vim.g.loaded_cheetah = 1

-- Define user commands if needed
vim.api.nvim_create_user_command('CheetahKeymaps', function()
  require('cheetah.commands.keymaps').keymaps_cheatsheet()
end, {
  desc = "Create buffer with keymaps cheatsheet"
})

-- The plugin will need to be explicitly set up by the user in their config:
-- require('cheetah').setup({})
