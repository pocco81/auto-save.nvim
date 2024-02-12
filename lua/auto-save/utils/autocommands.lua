local M = {}

local api = vim.api
local augroup_name = "AutoSave"

--- @param event TriggerEvent
--- @return VerboseTriggerEvent
local function parse_trigger_event(event)
  if type(event) == "string" then
    return { event }
  end
  return event
end

--- @param opts? table
--- @return number
M.create_augroup = function(opts)
  opts = opts or { clear = true }
  return api.nvim_create_augroup(augroup_name, opts)
end

--- @param pattern string
--- @param data? table
M.exec_autocmd = function(pattern, data)
  local opts = { pattern = pattern }
  if data ~= nil then
    opts.data = data
  end
  api.nvim_exec_autocmds("User", opts)
end

--- @param trigger_events TriggerEvent[]?
M.create_autocmd_for_trigger_events = function(trigger_events, autocmd_opts)
  if trigger_events ~= nil then
    for _, event in pairs(trigger_events) do
      local parsed_event = parse_trigger_event(event)
      local autocmd_opts_with_pattern = vim.tbl_extend("force", autocmd_opts, { pattern = parsed_event.pattern })
      api.nvim_create_autocmd(parsed_event[1], autocmd_opts_with_pattern)
    end
  end
end

return M
