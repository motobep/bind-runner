# bind-runner

A neovim plugin for binding custom commands to keystrokes and running them in a scratch buffer.

## Installation
* Install using your plugin manager (vim-plug in this example)
```vim
Plug 'nvim-lua/plenary.nvim' " dependency
Plug 'motobep/bind-runner'
```

## Setup
* In your vimrc
```vim
lua require('bind-runner')
```
* In your init.lua
```lua
require('bind-runner')
```

## Usage
Run __:BindRunner__ in vim command line and enter your command.

Then hit \<F5\> to run your custom command.
