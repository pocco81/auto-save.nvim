local config = {}

config.options = {
    enabled = true,
    execution_message = "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"),
    events = {"InsertLeave", "TextChanged"},
	conditions = {
		exists = true,
		filename_is_not = {},
		filetype_is_not = {},
		filetype_is = {},
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
