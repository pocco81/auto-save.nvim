local cmd = vim.cmd

local opts = require("autosave.config").options
local autocmds = require("autosave.modules.autocmds")
local autosave = require("autosave")
local status_autosave

require("autosave.utils.viml_funcs")

local M = {}


local function set_status(value)
	status_autosave = value
end

local function get_status()
	return status_autosave
end

local function on()

	if (autosave.hook_before_on ~= nil) then
		autosave.hook_before_on()
	end

	autocmds.load_autocommands()
	set_status('on')

	if (autosave.hook_after_on ~= nil) then
		autosave.hook_after_on()
	end
end

local function off()

	if (autosave.hook_before_off ~= nil) then
		autosave.hook_before_off()
	end

	autocmds.unload_autocommands()
	set_status('off')

	if (autosave.hook_after_off ~= nil) then
		autosave.hook_after_off()
	end
end

function M.main(option)
	option = option or 'load'

	if (option == 'toggle') then
		if (get_status() == 'on') then
			off()
		else
			on()
		end
	elseif (option == 'on') then
		on()
	elseif (option == 'off') then
		off()
	end
end

return M
