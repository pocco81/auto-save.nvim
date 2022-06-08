local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local opts = require("autosave.config").options
local autosave = require("autosave")
local default_events = { "InsertLeave", "TextChanged" }

local global_vars = {}

local M = {}

local function table_has_value(tbl, value)
	for key, _ in pairs(tbl) do
		if tbl[key] == value then
			return true
		end
	end

	return false
end

local function set_buf_var(buf, name, value)
    if buf == nil then
        global_vars[name] = value
    else
        vim.api.nvim_buf_set_var(buf, 'autosave_' .. name, value)
    end
end

local function get_buf_var(buf, name)
    if buf == nil then
        return global_vars[name]
    end
    local success, mod = pcall(vim.api.nvim_buf_get_var, buf, 'autosave_' .. name)
    return success and mod or nil
end

local function actual_save(buf)
	-- might use  update, but in that case it can't be checked if a file was modified and so it will always
	-- print opts["execution_message"]
	buf = buf or vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_get_option(buf, 'modified') then
		local first_char_pos = fn.getpos("'[")
		local last_char_pos = fn.getpos("']")

		if opts["write_all_buffers"] then
			cmd("silent! wall")
		else
			vim.api.nvim_buf_call(buf, function () cmd("silent! write") end)
		end

		fn.setpos("'[", first_char_pos)
		fn.setpos("']", last_char_pos)

        local buf_saved = not opts["write_all_buffers"] and buf or nil

		if get_buf_var(buf_saved, 'modified') == nil or get_buf_var(buf_saved, 'modified') == false then
			set_buf_var(buf_saved, 'modified', true)
		end

		M.message_and_interval(buf_saved)
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

function M.message_and_interval(buf)
	if get_buf_var(buf, 'modified') == true then
		set_buf_var(buf, 'modified', false)
		local execution_message = opts["execution_message"]
		if execution_message ~= "" then
			print(type(execution_message) == "function" and execution_message(buf) or execution_message)
            M.last_notified_buf = buf
		end

		if opts["clean_command_line_interval"] > 0 then
			cmd(
				[[call timer_start(]]
					.. opts["clean_command_line_interval"]
					.. [[, funcref('g:AutoSaveClearCommandLine', []] .. (buf or 'v:null') .. [[]))]]
			)
		end
	end
end

local function debounce(lfn, duration)
	local function inner_debounce()
        local buf = vim.api.nvim_get_current_buf()
		if not get_buf_var(buf, 'queued') then
			vim.defer_fn(function()
                set_buf_var(buf, 'queued', false)
				lfn(buf)
			end, duration)
            set_buf_var(buf, 'queued', true)
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
