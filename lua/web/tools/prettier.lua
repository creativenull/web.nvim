local utils = require("web.utils")
local M = {}

function M.get_executable()
	local tool = string.format("%s/node_modules/.bin/prettier", vim.loop.cwd())
	local global_tool = vim.fn.exepath("prettier")

	if vim.fn.filereadable(tool) == 0 and vim.fn.filereadable(global_tool) == 0 then
		return ""
	elseif vim.fn.filereadable(tool) == 1 and vim.fn.filereadable(global_tool) == 0 then
		return tool
	else
		return global_tool
	end
end

function M.format()
	local buf = vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(buf)
	local bufcontents = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local tool = M.get_executable()

	if tool == "" then
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
