-- inspired from https://github.com/nvim-lua/plenary.nvim/blob/master/lua/plenary/log.lua

local M = {}

local outfile = string.format("%s/auto-save.log", vim.api.nvim_call_function("stdpath", { "cache" }))

-- it could be that the directory of the file does not exist
-- this would require further checks, see https://github.com/nvim-lua/plenary.nvim/blob/master/lua/plenary/log.lua#L138
--- @param message string
local write_to_outfile = function(message)
  local f = assert(io.open(outfile, "a"))
  f:write(message)
  f:close()
end

M.new = function(options)
  local enabled = options.debug

  --- @param buf number | nil
  --- @param message string
  local log = function(buf, message)
    if not enabled then
      return
    end

    local log_message
    if buf ~= nil then
      local filename = vim.api.nvim_buf_get_name(buf)
      log_message = string.format("[%s] [%s] - %s\n", os.date(), filename, message)
    else
      log_message = string.format("[%s] - %s\n", os.date(), message)
    end

    write_to_outfile(log_message)
  end

  return {
    log = log,
  }
end

return M
