# GoBackLast Plugin

A simple Neovim plugin to save and return to the last cursor position, window, tab, and buffer.

## Features

- Saves the last cursor position when leaving a buffer, window, or tab.
- Optionally saves the current tab and window.
- Allows you to return to the last saved position with a custom command.

## Installation

### Using `vim-plug`:

```vim
Plug 'howardng97/goback.nvim'
```

### Using `packer.nvim`:

```lua
use 'howardng97/goback.nvim'
```

### Using `lazy.nvim`:

```lua
return {
    {
        "howardng97/goback.nvim",
        config = function()
        end
    }
}
```

### Commands

- :GoBackLast - Go back to the last saved buffer, window, tab, and cursor position.

### Example

- Open a file, move the cursor around, and switch between buffers, windows, or tabs.

- Type :GoBackLast to return to the last position, window, tab, and buffer.

### Configuration

You can configure whether to save the tab and window when switching by setting the save_tab and save_win options:

    - save_tab: Boolean (default true), whether to save the tab position.

    - save_win: Boolean (default true), whether to save the window position.

### Example:

```lua
require('goback').setup({
  save_tab = true,
  save_win = true,
})
```

### License:

It's free
