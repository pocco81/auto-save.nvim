local autocmds = require("autosave.modules.autocmds")
local autosave = require("autosave")
local g = vim.g
local M = {}
require("autosave.utils.viml_funcs")

local function on()

	if (autosave.hook_before_on ~= nil) then
		autosave.hook_before_on()
	end

	autocmds.load_autocommands()
	g.autosave_state = true

	if (autosave.hook_after_on ~= nil) then
		autosave.hook_after_on()
	end
end

local function off()

	if (autosave.hook_before_off ~= nil) then
		autosave.hook_before_off()
	end

	autocmds.unload_autocommands()
	g.autosave_state = false

	if (autosave.hook_after_off ~= nil) then
		autosave.hook_after_off()
	end
end

function M.main(option)
	option = option or 'load'

	if (option == 'toggle') then
		if (g.autosave_state == true) then
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
