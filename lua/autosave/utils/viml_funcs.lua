local api = vim.api

api.nvim_exec(
    [[
	function! g:AutoSaveClearCommandLine(timer)
		if mode() != 'c'
			echon ''
		endif
	endfunction
]],
    false
)
