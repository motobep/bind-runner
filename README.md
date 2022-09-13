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
Run __:BindRunner__ in vim command line, enter your command and the desired key that will trigger the command.<br>
If the key is not specified, \<F5\> is used as a default one.<br>
Example:
```
BindRunner prompt
Command: echo hi
Key:
Default key is used: <F5>
```

Then hit _the key_ to run your custom command.
