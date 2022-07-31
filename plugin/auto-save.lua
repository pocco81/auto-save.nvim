if vim.g.loaded_auto_save then
  return
end
vim.g.loaded_auto_save = true

local command = vim.api.nvim_create_user_command
local cnf = require("auto-save.config").options

command("AToggle", function()
	require("auto-save").toggle()
end, {})

if cnf.enabled then
	require("auto-save").on()
end
