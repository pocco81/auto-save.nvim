<!-- panvimdoc-ignore-start -->
<p align="center">
  <h1 align="center">🧶 auto-save.nvim</h1>
</p>

<p align="center">
  <b>auto-save.nvim</b> is a lua plugin for automatically saving your changed buffers in Neovim<br>
  Forked from <a href="https://github.com/Pocco81/auto-save.nvim">auto-save.nvim</a> as active development has stopped
</p>

<p align="center">
  <a href="https://github.com/okuuva/auto-save.nvim/stargazers">
    <img alt="Stars" src="https://img.shields.io/github/stars/okuuva/auto-save.nvim?style=for-the-badge">
  </a>
  <a href="https://github.com/okuuva/auto-save.nvim/issues">
    <img alt="Issues" src="https://img.shields.io/github/issues/okuuva/auto-save.nvim?style=for-the-badge">
  </a>
  <a href="https://github.com/okuuva/auto-save.nvim/blob/main/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/okuuva/auto-save.nvim?style=for-the-badge">
  </a>
  <a href="https://github.com/okuuva/auto-save.nvim">
    <img alt="Repo Size" src="https://img.shields.io/github/repo-size/okuuva/auto-save.nvim?style=for-the-badge"/>
  </a>
</p>

<!-- panvimdoc-ignore-end -->

## 📋 Features

- automatically save your changes so the world doesn't collapse
- highly customizable:
  - conditionals to assert whether to save or not
  - execution message (it can be dimmed and personalized)
  - events that trigger auto-save
- debounce the save with a delay
- hook into the lifecycle with autocommands
- automatically clean the message area

## 📚 Requirements

- Neovim >= 0.8.0

## 📦 Installation

Install the plugin with your favourite package manager:

### [Lazy.nvim]("https://github.com/folke/lazy.nvim")

```lua
{
  "okuuva/auto-save.nvim",
  cmd = "ASToggle", -- optional for lazy loading on command
  event = { "InsertLeave", "TextChanged" } -- optional for lazy loading on trigger events
  opts = {
    -- your config goes here
    -- or just leave it empty :)
  },
},
```

### [Packer.nvim]("https://github.com/wbthomason/packer.nvim")

```lua
use({
  "okuuva/auto-save.nvim",
  config = function()
   require("auto-save").setup {
     -- your config goes here
     -- or just leave it empty :)
   }
  end,
})
```

### [vim-plug]("https://github.com/junegunn/vim-plug")

```vim
Plug 'okuuva/auto-save.nvim'
lua << EOF
  require("auto-save").setup {
    -- your config goes here
    -- or just leave it empty :)
  }
EOF
```

</details>

## ⚙️ Configuration

**auto-save** comes with the following defaults:

```lua
{
  enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
  execution_message = {
    enabled = true,
    message = function() -- message to print on save
      return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
    end,
    dim = 0.18, -- dim the color of `message`
    cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
  },
  trigger_events = { -- See :h events
    immediate_save = { "BufLeave", "FocusLost" }, -- vim events that trigger an immediate save
    defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
    cancel_defered_save = { "InsertEnter" }, -- vim events that cancel a pending deferred save
  },
  -- function that takes the buffer handle and determines whether to save the current buffer or not
  -- return true: if buffer is ok to be saved
  -- return false: if it's not ok to be saved
  -- if set to `nil` then no specific condition is applied
  condition = nil,
  write_all_buffers = false, -- write all buffers when the current one meets `condition`
  noautocmd = false, -- do not execute autocmds when saving
  debounce_delay = 1000, -- delay after which a pending save is executed
 -- log debug messages to 'auto-save.log' file in neovim cache directory, set to `true` to enable
  debug = false,
}
```

### Condition

The condition field of the configuration allows the user to exclude **auto-save** from saving specific buffers.

Here is an example using a helper function from `auto-save.utils.data` that disables auto-save for specified file types:

```lua
{
  condition = function(buf)
    local fn = vim.fn
    local utils = require("auto-save.utils.data")

    -- don't save for `sql` file types
    if utils.not_in(fn.getbufvar(buf, "&filetype"), {'sql'}) then
      return true
    end
    return false
  end
}
```

You may also exclude `special-buffers` see (`:h buftype` and `:h special-buffers`):

```lua
{
  condition = function(buf)
    local fn = vim.fn

    -- don't save for special-buffers
    if fn.getbufvar(buf, "&buftype") ~= '' then
      return false
    end
    return true
  end
}
```

Buffers that are `nomodifiable` are not saved by default.

## 🚀 Usage

Besides running auto-save at startup (if you have `enabled = true` in your config), you may as well:

- `ASToggle`: toggle auto-save

You may want to set up a key mapping for toggling:

```lua
vim.api.nvim_set_keymap("n", "<leader>n", ":ASToggle<CR>", {})
```

or as part of the `lazy.nvim` plugin spec:

```lua
{
  "okuuva/auto-save.nvim",
  keys = {
    { "<leader>n", ":ASToggle<CR>", desc = "Toggle auto-save" },
  },
  ...
},

```

## 🪝 Events / Callbacks

The plugin fires events at various points during its lifecycle which users can hook into:

- `AutoSaveWritePre` Just before a buffer is getting saved
- `AutoSaveWritePost` Just after a buffer is getting saved

It will always supply the current buffer in the `data.saved_buffer`

An example to always print the file name before a file is getting saved (use `:messages` if the execution message swallows the print):

```lua
local group = vim.api.nvim_create_augroup('autosave', {})

vim.api.nvim_create_autocmd('User', {
    pattern = 'AutoSaveWritePre',
    group = group,
    callback = function(opts)
        if opts.data.saved_buffer ~= nil then
            local filename = vim.api.nvim_buf_get_name(opts.data.saved_buffer)
            print('We are about to save ' .. filename .. ' get ready captain!')
        end
    end,
})
```

If you want more Events, feel free to open an issue.

## 🤝 Contributing

- All pull requests are welcome.
- If you encounter bugs please open an issue.
- Please use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) when commiting.
  - See [@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional) for more details.

## 👋 Acknowledgements

This plugin wouldn't exist without [Pocco81](https://github.com/Pocco81)'s work on the [original](https://github.com/Pocco81/auto-save.nvim).
