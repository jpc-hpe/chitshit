# cheetah Neovim Plugin

An experimental Lua plugin for Neovim.

Self-note: I renamed the plugin to `cheetah` for easier replacement later. But both in this readme and in the doc/cheetah.txt file there is a still a reference to testplugin.vim because this is the repository name today.
TODO: fix once repository has a final name

## Features

- Keymaps visualization functionality. But for dynamic help you may prefer using [which-key.nvim](https://github.com/folke/which-key.nvim)
- Easily extensible architecture
- Configurable through setup options

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'jpc-hpe/testplugin.nvim',
  config = function()
    require('cheetah').setup{}
  end
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "jpc-hpe/testplugin.nvim",
  name="cheetah",
  opts = {},
}    
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'jpc-hpe/testplugin.nvim'
```

After installation, include in your configuration:

```lua
require('cheetah').setup{}
```

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

---

This repository started as a sandbox for experimenting with Neovim's Lua API. More features will be added as development continues.
