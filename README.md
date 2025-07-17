# jpc-hpe Neovim Plugin

An experimental Lua plugin for Neovim.

## Features

- Simple "Hello World" functionality
- Easily extensible architecture
- Configurable through setup options

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'jpc-hpe/nvim.plugin',
  config = function()
    require('jpc-hpe').setup{}
  end
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'jpc-hpe/nvim.plugin',
  config = function()
    require('jpc-hpe').setup{}
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'jpc-hpe/nvim.plugin'
```

After installation, include in your configuration:
```lua
require('jpc-hpe').setup{}
```

## Configuration

You can configure the plugin by passing options to the setup function:

```lua
require('jpc-hpe').setup({
  enabled = true,
  -- Add more configuration options as needed
})
```

## Commands

- `:JpcHpeHello` - Display a hello message from the plugin

## API

- `require('jpc-hpe').setup(opts)` - Initialize the plugin with options
- `require('jpc-hpe').hello_world()` - Display a hello message

## License

MIT License, see [LICENSE](LICENSE) for details.

---

This repository started as a sandbox for experimenting with Neovim's Lua API. More features will be added as development continues.
