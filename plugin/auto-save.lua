local command = vim.api.nvim_create_user_command

command("ASToggle", function()
  require("auto-save").toggle()
end, {})
