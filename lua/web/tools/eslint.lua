local utils = require("web.utils")
local M = {}

function M.get_executable()
	local tool = string.format("%s/node_modules/.bin/eslint", vim.loop.cwd())

	if vim.fn.filereadable(tool) == 0 then
		return ""
	end

	return tool
end

function M.format()
	local buf = vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(buf)
	local tool = M.get_executable()

	if tool == "" then
		utils.err.writeln("Eslint not installed. Install with `npm i -D eslint`.")
		return
	end

	local command = { tool, "--fix", filename }
	local winstate = vim.call("winsaveview")
	vim.fn.jobstart(command, {
		on_exit = function()
			vim.cmd("silent edit!")
			vim.call("winrestview", winstate)
		end,
    stdout_buffered = true,
		on_stdout = function(_, data, _)
			if #data > 0 and #data == 1 and data[1] == "" then
				-- No errors
				return
			end

			utils.err.writeln("Eslint could not format due to errors")
		end,
	})
end

return M
