local api = vim.api

api.nvim_exec(
    [[
	function! g:AutoSaveClearCommandLine(buf, timer)
		if mode() != 'c' && luaeval("require'autosave.modules.autocmds'.last_notified_buf") == a:buf
			echon ''
		endif
	endfunction
]],
    false
)
