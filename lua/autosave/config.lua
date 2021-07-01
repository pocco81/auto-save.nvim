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
        -- check if option exists in the config's table
        if (config.options[opt] ~= nil) then -- not nil
            -- chec if option is a table
            if (type(opts[opt]) == "table") then -- if table
                for inner_opt, _ in pairs(opts[opt]) do
                    -- table contains element by that key
                    if (config.options[opt][inner_opt] ~= nil) then -- not nil
                        config.options[opt][inner_opt] = opts[opt][inner_opt]
                    end
                end
            else
                config.options[opt] = opts[opt]
            end
        end
    end
end

return config
