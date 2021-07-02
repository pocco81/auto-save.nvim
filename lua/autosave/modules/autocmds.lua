local opts = require("autosave.config").options

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local M = {}

local function table_has_value(tbl, value)
    for key, _ in pairs(tbl) do
        if (tbl[key] == value) then
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
    -- might use  update, but in that case it can't be checekd if a file was modified and so it will always
    -- print opts["execution_message"]
    if (api.nvim_eval([[&modified]]) == 1) then
        cmd("silent! write")
        if (get_modified() == nil or get_modified() == false) then
            set_modified(true)
        end
    end
end

local function assert_user_conditions()
    local sc_exists, sc_filetype, sc_modifiable = true, true, true

    for condition, value in pairs(opts["conditions"]) do
        if (condition == "exists") then
            if (value == true) then
                if (fn.filereadable(fn.expand("%:p")) == 0) then
                    sc_exists = false; break
                end
            end
        elseif (condition == "modifiable") then
            if (value == true) then
                if (api.nvim_eval([[&modifiable]]) == 0) then
                    sc_modifiable = false; break
                end
            end
        elseif (condition == "filetype_is_not") then
            if not (next(opts["conditions"]["filetype_is_not"]) == nil) then
                if (table_has_value(opts["conditions"]["filetype_is_not"], api.nvim_eval([[&filetype]])) == true) then
                    sc_filetype = false; break
                end
            end
        end
    end

    return {sc_exists, sc_filetype, sc_modifiable}
end

local function assert_return(values, expected)
	for key, value in pairs(values) do
		if (value ~= expected) then return false end
	end

	return true
end

function M.do_save()
	if (assert_return(assert_user_conditions(), true)) then
		actual_save()
	end
end

function M.save()
    if (opts["write_all_buffers"] == true) then
        cmd([[call g:AutoSaveBufDo("lua require'autosave.modules.autocmds'.do_save()")]])
    else
        M.do_save()
    end

    if (opts["execution_message"] ~= "" and get_modified() == true) then
        print(opts["execution_message"])
        set_modified(false)
    end

    if (opts["clean_command_line_interval"] > 0) then
        cmd(
            [[call timer_start(]] .. opts["clean_command_line_interval"] .. [[, funcref('g:AutoSaveClearCommandLine'))]]
        )
    end
end

local function parse_events()
    local events = ""

    if (next(opts["events"]) == nil) then
        events = "InsertLeave"
    else
        for event, _ in pairs(opts["events"]) do
            events = events .. opts["events"][event] .. ","
        end
    end

    return events
end

function M.load_autocommands()
    api.nvim_exec(
        [[
		augroup autosave_save
			autocmd!
			autocmd ]] ..
            parse_events() ..
                [[ * if (&modifiable == 1) | execute "lua require'autosave.modules.autocmds'.save()" | endif
		augroup END
	]],
        false
    )
end

function M.unload_autocommands()
    api.nvim_exec([[
		augroup autosave_save
			autocmd!
		augroup END
	]], false)
end

return M
