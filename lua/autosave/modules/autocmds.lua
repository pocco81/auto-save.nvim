local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local opts = require("autosave.config").options
local autosave = require("autosave")
local default_events = { "InsertLeave", "TextChanged" }

local modified

local M = {}

local function table_has_value(tbl, value)
	for key, _ in pairs(tbl) do
		if tbl[key] == value then
			return true
		end
	end

	return false
end

local function set_modified(value)
	modified = value
end

local function get_modified()
	return modified
end

local function actual_save()
	-- might use  update, but in that case it can't be checked if a file was modified and so it will always
	-- print opts["execution_message"]
	if api.nvim_eval([[&modified]]) == 1 then
		if autosave.hook_before_actual_saving ~= nil then
			autosave.hook_before_actual_saving()
		end

		if vim.g.auto_save_abort then
			return
		end

		local first_char_pos = fn.getpos("'[")
		local last_char_pos = fn.getpos("']")

		if opts["write_all_buffers"] then
			cmd("silent! wall")
		else
			cmd("silent! write")
		end

		fn.setpos("'[", first_char_pos)
		fn.setpos("']", last_char_pos)

		if get_modified() == nil or get_modified() == false then
			set_modified(true)
		end

		M.message_and_interval()
	end
end

local function assert_user_conditions()
	local sc_exists, sc_filename, sc_filetype, sc_modifiable = true, true, true, true

	for condition, value in pairs(opts["conditions"]) do
		if condition == "exists" then
			if value == true then
				if fn.filereadable(fn.expand("%:p")) == 0 then
					sc_exists = false
					break
				end
			end
		elseif condition == "modifiable" then
			if value == true then
				if api.nvim_eval([[&modifiable]]) == 0 then
					sc_modifiable = false
					break
				end
			end
		elseif condition == "filename_is_not" then
			if not (next(opts["conditions"]["filename_is_not"]) == nil) then
				if table_has_value(opts["conditions"]["filename_is_not"], vim.fn.expand('%:t')) == true then
					sc_filename = false
					break
				end
			end
		elseif condition == "filetype_is_not" then
			if not (next(opts["conditions"]["filetype_is_not"]) == nil) then
				if table_has_value(opts["conditions"]["filetype_is_not"], api.nvim_eval([[&filetype]])) == true then
					sc_filetype = false
					break
				end
			end
		end
	end

	return { sc_exists, sc_filename, sc_filetype, sc_modifiable }
end

local function assert_return(values, expected)
	for key, value in pairs(values) do
		if value ~= expected then
			return false
		end
	end

	return true
end

function M.message_and_interval()
	if get_modified() == true then
		set_modified(false)
		local execution_message = opts["execution_message"]
		if execution_message ~= "" then
			print(type(execution_message) == "function" and execution_message() or execution_message)
		end

		if opts["clean_command_line_interval"] > 0 then
			cmd(
				[[call timer_start(]]
					.. opts["clean_command_line_interval"]
					.. [[, funcref('g:AutoSaveClearCommandLine'))]]
			)
		end
	end
end

local function debounce(lfn, duration)
	local queued = false

	local function inner_debounce()
		if not queued then
			vim.defer_fn(function()
				queued = false
				lfn()
			end, duration)
			queued = true
		end
	end

	return inner_debounce
end

function M.do_save()
	if assert_return(assert_user_conditions(), true) then
		M.debounced_save()
	end
end

function M.save()
    vim.g.auto_save_abort = false

	if autosave.hook_before_saving ~= nil then
		autosave.hook_before_saving()
	end

    if vim.g.auto_save_abort then
        return
    end

	M.do_save()

	if autosave.hook_after_saving ~= nil then
		autosave.hook_after_saving()
	end
end

local function get_events()
	if next(opts["events"]) == nil or opts["events"] == nil then
		return default_events
	else
		return opts["events"]
	end
end

local function parse_events()
	return table.concat(get_events(), ",")
end

function M.load_autocommands()
	if opts["debounce_delay"] == 0 then
		M.debounced_save = actual_save
	else
		M.debounced_save = debounce(actual_save, opts["debounce_delay"])
	end

	api.nvim_exec([[
		aug autosave_save
			au!
			au ]] .. parse_events() .. [[ * execute "lua require'autosave.modules.autocmds'.save()"
		aug END
	]], false)
end

function M.unload_autocommands()
	api.nvim_exec(
		[[
		aug autosave_save
			au!
		aug END
	]],
		false
	)
end

return M
