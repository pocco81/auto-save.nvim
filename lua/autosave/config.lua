local config = {}

config.options = {
    enabled = true,
    execution_message = "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"),
    events = {"InsertLeave", "TextChanged"},
    write_all_buffers = false,
    on_off_commands = false,
    save_only_if_exists = true,
    excluded_filetypes = {}
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
