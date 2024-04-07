local M = {}

function M.host_info()
	local ver = vim.version()
	return string.format("NVIM v%d.%d.%d", ver.major, ver.minor, ver.patch)
end

M.fs = {}

function M.fs.find_nearest(list)
	return vim.fs.dirname(vim.fs.find(list, { upward = true })[1])
end

M.err = {}

function M.err.writeln(msg)
  vim.api.nvim_notify(string.format("[web.nvim] %s", msg), vim.log.levels.WARN, {})
end

return M
