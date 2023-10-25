local M = {}

function M.fmt_current_buf()
	local buf = vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(buf)
	local winstate = vim.call("winsaveview")

	vim.cmd("write")
	vim.fn.system({ string.format("%s/node_modules/.bin/eslint", vim.loop.cwd()), "--fix", filename })

	vim.cmd("edit!")
	vim.call("winrestview", winstate)
end

return M
