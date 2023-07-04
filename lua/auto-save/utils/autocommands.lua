local M = {}

local api = vim.api
local augroup_name = "AutoSave"

--- @param opts? table
--- @return number
M.create_augroup = function(opts)
  opts = opts or { clear = true }
  return api.nvim_create_augroup(augroup_name, opts)
end

--- @param pattern string
--- @param saved_buffer number
M.exec_autocmd = function(pattern, saved_buffer)
  api.nvim_exec_autocmds("User", { pattern = pattern, data = { saved_buffer = saved_buffer } })
end

return M
