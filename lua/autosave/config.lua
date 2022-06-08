local config = {}

config.options = {
    enabled = true,
    execution_message = function (buf)
        return ("AutoSave: saved "
            .. (buf == nil and '*' or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t'))
            .. " at " .. vim.fn.strftime("%H:%M:%S"))
    end,
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
}

function config.set_options(opts)
    opts = opts or {}

    for opt, _ in pairs(opts) do
        if (config.options[opt] ~= nil) then -- not nil
			config.options[opt] = opts[opt]
        end
    end
end

return config
