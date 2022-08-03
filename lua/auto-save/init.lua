local M = {}

local cnf = require("auto-save.config").options
local callback = require("auto-save.utils.data").do_callback
local colors = require("auto-save.utils.colors")
local echo = require("auto-save.utils.echo")
local autosave_running
local api = vim.api
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd
local o = vim.o
local AUTO_SAVE_COLOR = "MsgArea"

api.nvim_create_augroup("AutoSave", {
	clear = true,
})

local global_vars = {}

local function set_buf_var(buf, name, value)
    if buf == nil then
        global_vars[name] = value
    else
        api.nvim_buf_set_var(buf, 'autosave_' .. name, value)
    end
end

local function get_buf_var(buf, name)
    if buf == nil then
        return global_vars[name]
    end
    local success, mod = pcall(api.nvim_buf_get_var, buf, 'autosave_' .. name)
    return success and mod or nil
end

local function debounce(lfn, duration)
	local function inner_debounce()
        local buf = api.nvim_get_current_buf()
		if not get_buf_var(buf, 'queued') then
			vim.defer_fn(function()
                set_buf_var(buf, 'queued', false)
				lfn(buf)
			end, duration)
            set_buf_var(buf, 'queued', true)
		end
	end

	return inner_debounce
end

function M.save(buf)
	buf = buf or api.nvim_get_current_buf()

	callback("before_asserting_save")

	if cnf.condition(buf) == false then
		return
	end

	if not api.nvim_buf_get_option(buf, 'modified') then
		return
	end

	callback("before_saving")

	if g.auto_save_abort == true then
		return
	end

	if cnf.write_all_buffers then
		cmd("silent! wall")
	else
		api.nvim_buf_call(buf, function () cmd("silent! write") end)
	end

	callback("after_saving")

	api.nvim_echo({ { (type(cnf.execution_message.message) == "function" and cnf.execution_message.message() or cnf.execution_message.message), AUTO_SAVE_COLOR } }, true, {})
	if cnf.execution_message.cleaning_interval > 0 then
		fn.timer_start(
			cnf.execution_message.cleaning_interval,
			function()
				cmd([[echon '']])
			end
		)
	end
end

local save_func = (cnf.debounce_delay > 0 and debounce(M.save, cnf.debounce_delay) or M.save)

local function perform_save()
	g.auto_save_abort = false
	save_func()
end

function M.on()
	api.nvim_create_autocmd(cnf.trigger_events, {
		callback = function()
			perform_save()
		end,
		pattern = "*",
		group = "AutoSave",
	})

	api.nvim_create_autocmd({"VimEnter", "ColorScheme"}, {
		callback = function()
			vim.schedule(function()
				if cnf.execution_message.dim > 0 then
					MSG_AREA = colors.get_hl("MsgArea")
					MSG_AREA.background = (MSG_AREA.background or colors.get_hl("Normal")["background"])
					local foreground = (
						o.background == "dark" and
							colors.darken((MSG_AREA.background or "#000000"), cnf.execution_message.dim, MSG_AREA.foreground) or
							colors.lighten((MSG_AREA.background or "#ffffff"), cnf.execution_message.dim, MSG_AREA.foreground)
						)

					colors.highlight("AutoSaveText", { fg = foreground })
					AUTO_SAVE_COLOR = "AutoSaveText"
				end
			end)
		end,
		pattern = "*",
		group = "AutoSave",
	})

	callback("enabling")
	autosave_running = true
end

function M.off()

	api.nvim_create_augroup("AutoSave", {
		clear = true,
	})

	callback("disabling")
	autosave_running = false
end

function M.toggle()
	if autosave_running then
		M.off()
		echo("off")
	else
		M.on()
		echo("on")
	end
end

function M.setup(custom_opts)
	require("auto-save.config").set_options(custom_opts)
end

return M
