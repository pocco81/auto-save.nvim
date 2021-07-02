local api = vim.api

-- original source: https://vim.fandom.com/wiki/Run_a_command_in_multiple_buffers
-- like bufdo but restore the current buffer.
api.nvim_exec(
    [[
	function! g:AutoSaveBufDo(command)

		let b:autosave_view_before_bufdo = winsaveview()

		let currBuff=bufnr("%")
		execute 'bufdo ' . a:command
		execute 'buffer ' . currBuff

		call winrestview(b:autosave_view_before_bufdo)
		unlet b:autosave_view_before_bufdo

	endfunction
	com! -nargs=+ -complete=command Bufdo call BufDo(<q-args>)
]],
    false
)

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
