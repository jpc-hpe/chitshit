# cheetah Neovim Plugin

An experimental Lua plugin for Neovim showing cheat sheets.
The repository is mostly intended for me to learn about neovim and lus, but if you find it useful, feel free to use it!


## Features

- Keymaps cheat sheet. But for dynamic help you may prefer using [which-key.nvim](https://github.com/folke/which-key.nvim). It also shows ant end the available `<Leader>` combinations that you can use.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim) (TESTED)

```lua
{
  "jpc-hpe/cheetah.nvim",
  name="cheetah",
  opts = {},
}    
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim) (UNTESTED)

```lua
use {
  'jpc-hpe/cheetah.nvim',
  config = function()
    require('cheetah').setup{}
  end
}
```



### Using [vim-plug](https://github.com/junegunn/vim-plug) (UNTESTED)

```vim
Plug 'jpc-hpe/cheetah.nvim'
```

After installation, include in your configuration:

```lua
require('cheetah').setup{}
```

With lazy.nvim, you do not need this explicitly, as it already happens if you have `opts` in the spec

## Configuration

You can configure the plugin by passing options to the setup function:

```lua
require('cheetah').setup({
  enabled = true,
  -- Add more configuration options as needed
})
```

## Commands

- `:CheetahKeymaps` - Create buffer with keymaps cheatsheet

## API

- `require('cheetah').setup(opts)` - Initialize the plugin with options
- `require('cheetah.commands.keymaps').keymaps_cheatsheet()` - Create buffer with keymaps cheatsheet

## License

MIT License, see [LICENSE](LICENSE) for details.


