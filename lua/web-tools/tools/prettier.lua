local utils = require("web-tools.utils")
local M = {}

function M.format()
	local buf = vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(buf)
	local bufcontents = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local tool = string.format("%s/node_modules/.bin/prettier", vim.loop.cwd())

	if vim.fn.filereadable(tool) == 0 then
		utils.err.writeln("Prettier not installed. Install with `npm i -D prettier`.")
		return
	end

	local command = { tool, "--stdin-filepath", filename }
	local jobid = vim.fn.jobstart(command, {
		stdout_buffered = true,
		on_stdout = function(_, data, _)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
		end,
	})
	vim.fn.chansend(jobid, table.concat(bufcontents, "\n"))
	vim.fn.chanclose(jobid, "stdin")
end

return M
