# chitshit Neovim Plugin

An experimental Lua plugin for Neovim showing cheat sheets.
The repository is mostly intended for me to learn about neovim and lua, but if you find it useful, feel free to use it!

The original name was cheetah, but then I found that there is already a plugin with that name. The current name _chitshit_ is pronounced like "cheat sheet".

## Features

- Keymaps cheat sheet. But for dynamic help you may prefer using [which-key.nvim](https://github.com/folke/which-key.nvim).
  - It also shows at the end the available `<Leader>` combinations that you can use.
  - And it also shows you at the beginning your current `<Leader>` key

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim) (TESTED)

```lua
{
  "jpc-hpe/chitshit.nvim",
  opts = {},
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim) (UNTESTED)

```lua
use {
  'jpc-hpe/chitshit.nvim',
  config = function()
    require('chitshit').setup{}
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug) (UNTESTED)

```vim
Plug 'jpc-hpe/chitshit.nvim'
```

After installation, include in your configuration:

```lua
require('chitshit').setup{}
```

With lazy.nvim, you do not need this explicitly, as it already happens if you have `opts` in the spec

## Configuration

You can configure the plugin by passing options to the setup function:

```lua
require('chitshit').setup({
  enabled = true,
  -- Add more configuration options as needed
})
```

## Commands

- `:ChitshitKeymaps` - Create buffer with keymaps cheatsheet

## Key mappings

No keymap is provided by default.
I am personally planning to use `<Leader><Leader>c`+whatever as no other plugin is using the "double leader" combination.
The following is what I have in my `~/.nvim/lua/config/keymaps.lua` (yes, I use LazyVim):

```lua
vim.keymap.set(
  'n',
  '<Leader><Leader>ck',
  ':ChitshitKeymaps<CR>',
  {
    noremap = true,
    silent = true,
    desc = "Chitshit: Show keymaps cheatsheet"
  }
)

```

## API

- `require('chitshit').setup(opts)` - Initialize the plugin with options
- `require('chitshit.commands.keymaps').keymaps_cheatsheet()` - Create buffer with keymaps cheatsheet

## License

MIT License, see [LICENSE](LICENSE) for details.
