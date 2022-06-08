<h1 align="center">🦴 AutoSave.nvim</h1>

<p align="center">
	A NeoVim plugin for saving your work before the world collapses or you type :qa!
</p>

<p align="center">
    <a href="https://github.com/Pocco81/AutoSave.nvim/stargazers"
        ><img
            src="https://img.shields.io/github/stars/Pocco81/AutoSave.nvim"
            alt="Repository's starts"
    /></a>
    <a href="https://github.com/Pocco81/AutoSave.nvim/issues"
        ><img
            src="https://img.shields.io/github/issues-raw/Pocco81/AutoSave.nvim"
            alt="Issues"
    /></a>
    <a href="https://github.com/Pocco81/AutoSave.nvim/blob/main/LICENSE"
        ><img
            src="https://img.shields.io/github/license/Pocco81/AutoSave.nvim"
            alt="License"
    /><br />
    <a href="https://saythanks.io/to/Pocco81%40gmail.com"
        ><img
            src="https://img.shields.io/badge/say-thanks-modal.svg"
            alt="Say thanks"/></a
    ></a>    <a href="https://github.com/Pocco81/whid.nvim/commits/main"
    <a href="https://github.com/Pocco81/AutoSave.nvim/commits/main"
		><img
			src="https://img.shields.io/github/last-commit/Pocco81/AutoSave.nvim/dev"
			alt="Latest commit"
    /></a>
    <a href="https://github.com/Pocco81/AutoSave.nvim"
        ><img
            src="https://img.shields.io/github/repo-size/Pocco81/AutoSave.nvim"
            alt="GitHub repository size"
    /></a>
</p>

<kbd><img src ="https://raw.githubusercontent.com/Pocco81/AutoSave.nvim/dev/resources/demo.gif"></kbd>
<p align="center">
	Demo
</p><hr>


# TL;DR

<div style="text-align: justify">
	AutoSave.nvim is a NeoVim plugin written in Lua that aims to provide the simple functionality of automatically saving your work whenever you make changes to it. You can filter under which conditions which files are saved and when the auto-save functionality should be triggered (events). To get started simply install the plugin with your favorite plugin manager!
</div>

# 🌲 Table of Contents

* [Features](#-features)
* [Notices](#-notices)
* [Installation](#-installation)
	* [Prerequisites](#prerequisites)
	* [Adding the plugin](#adding-the-plugin)
	* [Setup Configuration](#setup-configuration)
		* [For init.lua](#for-initlua)
		* [For init.vim](#for-initvim)
	* [Updating](#updating)
* [Usage](#-usage)
	* [Commands](#commands)
		* [Default](#default)
		* [Extra](#extra)
	* [General](#general)
* [Configuration](#-configuration)
	* [General](#general)
	* [Conditions](#conditions)
	* [Hooks](#hooks)
	* [Recommendations](#recommendations)
* [Contribute](#-contribute)
* [Inspirations](#-inspirations)
* [License](#-license)
* [FAQ](#-faq)
* [To-Do](#-to-do)

# 🎁 Features
+ Automatically save current file(s).
+ Set conditions that files must meet to be saved (e.g. filetype, existence, ...).
+ Set events that will trigger the plugin.
+ Add custom hooks (e.g. print a message when the plugin is turned off).
+ Toggle the plugin on and off.

# 📺 Notices
Checkout the [CHANGELOG.md](https://github.com/Pocco81/AutoSave.nvim/blob/main/CHANGELOG.md) file for more information on the notices below:

+ **15-07-21**: Implemented debounce_delay setting thanks to #7 and "Preserve cursor marks" feature when saving thanks to #8.
+ **04-07-21**: Fixed #1.
+ **01-07-21**: Just released!

# 📦 Installation

## Prerequisites

- [NeoVim nightly](https://github.com/neovim/neovim/releases/tag/nightly) (>=v0.5.0)

## Adding the plugin
You can use your favorite plugin manager for this. Here are some examples with the most popular ones:

### Vim-plug

```lua
Plug 'Pocco81/AutoSave.nvim'
```
### Packer.nvim

```lua
use "Pocco81/AutoSave.nvim"
```

### Vundle

```lua
Plugin 'Pocco81/AutoSave.nvim'
```

### NeoBundle
```lua
NeoBundleFetch 'Pocco81/AutoSave.nvim'
```

## Setup (configuration)
As it's stated in the TL;DR, there are already some sane defaults that you may like, however you can change them to match your taste. These are the defaults:
```lua
enabled = true,
execution_message = function (buf)
  return ("AutoSave: saved "
    .. buf == nil and '*' or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
    .. " at " .. vim.fn.strftime("%H:%M:%S"))
end,
-- execution_message = "Saved",
events = {"InsertLeave", "TextChanged"},
conditions = {
	exists = true,
	filename_is_not = {},
	filetype_is_not = {},
	modifiable = true,
},
write_all_buffers = false,
on_off_commands = false,
clean_command_line_interval = 0,
debounce_delay = 135
```

The way you setup the settings on your config varies on whether you are using vimL for this or Lua.

<details>
    <summary>For init.lua</summary>
<p>

```lua
local autosave = require("autosave")

autosave.setup(
    {
        enabled = true,
        execution_message = function (buf)
            return ("AutoSave: saved "
                .. buf == nil and '*' or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
                .. " at " .. vim.fn.strftime("%H:%M:%S"))
        end,
        events = {"InsertLeave", "TextChanged"},
        conditions = {
            exists = true,
            filename_is_not = {},
            filetype_is_not = {},
            modifiable = true
        },
        write_all_buffers = false,
        on_off_commands = true,
        clean_command_line_interval = 0,
        debounce_delay = 135
    }
)
```
<br />
</details>


<details>
    <summary>For init.vim</summary>
<p>

```lua
lua << EOF
local autosave = require("autosave")

autosave.setup(
    {
        enabled = true,
        execution_message = function (buf)
            return ("AutoSave: saved "
                .. buf == nil and '*' or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
                .. " at " .. vim.fn.strftime("%H:%M:%S"))
        end,
        events = {"InsertLeave", "TextChanged"},
        conditions = {
            exists = true,
            filename_is_not = {},
            filetype_is_not = {},
            modifiable = true
        },
        write_all_buffers = false,
        on_off_commands = true,
        clean_command_line_interval = 0,
        debounce_delay = 135
    }
)
EOF
```
<br />
</details>

For instructions on how to configure the plugin, check out the [configuration](#configuration) section.

## Updating
This depends on your plugin manager. If, for example, you are using Packer.nvim, you can update it with this command:
```lua
:PackerUpdate
```

# 🤖 Usage

## Commands
All the commands follow the *camel casing* naming convention and have the `AS` prefix so that it's easy to remember that they are part of this plugin. These are all of them:

### Default
+ `:ASToggle`: toggles AutoSave.nvim on and off.

### Extra
+ `:ASOn`: turns AutoSave.nvim on.
+ `:ASOff`: turns AutoSave.nvim off.

## General
+ `vim.g.autosave_state`: use this to check whether AutoSave is on (`true`) or off (`false`).

# 🐬 Configuration
Although settings already have self-explanatory names, here is where you can find info about each one of them and their classifications!

## General
+ `enabled:`: (Boolean) if true, enables AutoSave.nvim at startup (Note: this is not for loading the plugin it self but rather the "auto-save" functionality. This is like running `:ASOn`).
+ `execution_message`: (String) message to be displayed when saving [a] file[s].
+ `events`: (Table): events that will trigger the plugin.
+ `write_all_buffers`: (Boolean) if true, writes to all modifiable buffers that meet the `conditions`.
+ `on_off_commands`: (Boolean) if true, enables extra commands for toggling the plugin on and off (`:ASOn` and `:ASOff`).
+ `clean_command_line_interval` (Integer) if greater than 0, cleans the command line after *x* amount of milliseconds after printing the `execution_message`.
+ `debounce_delay` (Integer) if greater than 0, saves the file at most every `debounce_delay` milliseconds, vastly improving editing performance. If 0 then saves are performed immediately after `events` occur. It's recommend to leave the default value (`135`), which is just long enough to reduce unnecessary saves, but short enough that you don't notice the delay.

## Conditions
These are the conditions that every file must meet so that it can be saved. If every file to be auto-saved doesn't meet all of the conditions it won't be saved.
+ `exists`: (Boolean) if true, enables this condition. If the file doesn't exist it won't save it (e.g. if you `nvim stuff.txt` and don't save the file then this condition won't be met)
+ `modifiable`: (Boolean) if true, enables this condition. If the file isn't modifiable, then this condition isn't met.
+ `filename_is_not`: (Table, Strings) if there is one or more filenames (should be strings) in the table, it enables this condition. Use this to exclude filenames that you don't want to automatically save.
+ `filetype_is_not`: (Table, Strings) if there is one or more filetypes (should be strings) in the table, it enables this condition. Use this to exclude filetypes that you don't want to automatically save.

## Hooks
Use them to execute code at certain events [described by their names]. These are the ones available:

| Function             | Description                                                        |
|----------------------|--------------------------------------------------------------------|
| hook_before_on()     | Before toggling the plugin on                                      |
| hook_after_on()      | After toggling the plugin on                                       |
| hook_before_off()    | Before toggling the plugin off                                     |
| hook_after_off()     | After toggling the plugin off                                      |
| hook_before_saving() | Before its even checked if the current file(s) meet the conditions |
| hook_after_saving    | After saving the file(s)                                           |

They can be used like so:

```lua
local autosave = require("autosave")

autosave.hook_after_off = function ()
	print("I was toggled off!")
end
```

The `hook_before_saving` hook can be used to abort saving based on some condition:

```lua
local autosave = require("autosave")

autosave.hook_before_saving = function ()
    if <condition> then
        vim.g.auto_save_abort = true -- Save will be aborted
    end
end
```

## Recommendations
+ Many other plugins/stuff that you may use rely on using the same events as the ones AutoSave uses by default or may need to interact with the buffer before it's saved. Mainly being plugins for snippets support. If this is your case, consider increasing the `debounce_delay` setting to your needs.

# 🙋 FAQ

- Q: ***"How can I view the doc from NeoVim?"***
- A: Use `:help AutoSave.nvim`

# 🫂 Contribute

Pull Requests are welcomed as long as they are properly justified and there are no conflicts. If your PR has something to do with the README or in general related with the documentation, I'll gladly merge it! Also, when writing code for the project **you must** use the [.editorconfig](https://github.com/Pocco81/AutoSave.nvim/blob/main/.editorconfig) file on your editor so as to "maintain consistent coding styles". For instructions on how to use this file refer to [EditorConfig's website](https://editorconfig.org/).

# 💭 Inspirations

The following projects inspired the creation of AutoSave.nvim. If possible, go check them out to see why they are so amazing :]
- [907th/vim-auto-save](https://github.com/907th/vim-auto-save): Automatically save changes to disk in Vim.

# 📜 License

AutoSave.nvim is released under the GPL v3.0 license. It grants open-source permissions for users including:

- The right to download and run the software freely
- The right to make changes to the software as desired
- The right to redistribute copies of the software
- The right to modify and distribute copies of new versions of the software

For more convoluted language, see the [LICENSE file](https://github.com/Pocco81/AutoSave.nvim/blob/main/LICENSE.md).

# 📋 TO-DO

**High Priority**
+ None

**Low Priority**
+ None

<hr>
<p align="center">
	Enjoy!
</p>
