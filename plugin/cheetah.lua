-- This file ensures the plugin is loaded properly
if vim.fn.has('nvim-0.7') == 0 then
  vim.api.nvim_err_writeln("chitshit requires at least Neovim 0.7")
  return
end

-- Prevent loading the plugin multiple times
if vim.g.loaded_chitshit == 1 then
  return
end
vim.g.loaded_chitshit = 1

-- Define user commands if needed
vim.api.nvim_create_user_command('ChitshitKeymaps', function()
  require('chitshit.commands.keymaps').keymaps_cheatsheet()
end, {
  desc = "Create buffer with keymaps cheatsheet"
})

-- The plugin will need to be explicitly set up by the user in their config:
-- require('chitshit').setup({})
