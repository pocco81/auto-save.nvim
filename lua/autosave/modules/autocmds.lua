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
        if (get_modified() == nil or get_modified() == false) then set_modified(true) end
    end
end

function M.do_save()
    local cs_exists, cs_filetype = true, true

    if not (next(opts["excluded_filetypes"]) == nil) then
        if (table_has_value(opts["excluded_filetypes"], api.nvim_eval([[&filetype]])) == true) then
            cs_filetype = false
        end
    end

    if (opts["save_only_if_exists"] == true) then
        if (fn.filereadable(fn.expand("%:p")) == 0) then
            cs_exists = false
        end
    end

    if (cs_exists == true and cs_filetype == true) then
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
            parse_events() .. [[ * execute "lua require'autosave.modules.autocmds'.save()"
		augroup END
	]],
        false
    )

    if (opts["clean_command_line_interval"] > 0) then
        api.nvim_exec(
            [[
			augroup autosave_clean_command_line
				autocmd!
				autocmd CmdlineLeave * call timer_start(]] ..
                opts["clean_command_line_interval"] .. [[, funcref('g:AutoSaveClearCommandLine'))
			augroup END
		]],
            false
        )
    end
end

function M.unload_autocommands()
    api.nvim_exec([[
		augroup autosave_save
			autocmd!
		augroup END
	]], false)

    if (opts["clean_command_line_interval"] > 0) then
        api.nvim_exec([[
			augroup autosave_clean_command_line
				autocmd!
			augroup END
		]], false)
    end
end

return M
