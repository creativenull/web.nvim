local M = {}

function M.host_info()
	local ver = vim.version()
	return string.format("NVIM v%d.%d.%d", ver.major, ver.minor, ver.patch)
end

M.fs = {}

function M.fs.find_nearest(list)
	return vim.fs.dirname(vim.fs.find(list, { upward = true })[1])
end

function M.fs.readfile(filepath)
	local fd = vim.loop.fs_open(filepath, "r", 438)
	local stat = vim.loop.fs_fstat(fd)
	local contents = vim.loop.fs_read(fd, stat.size)
	vim.loop.fs_close(fd)

	return contents
end

function M.fs.get_package_manager()
	local yarnlock = string.format("%s/yarn.lock", vim.loop.cwd())
	if vim.fn.filereadable(yarnlock) == 1 then
		return "yarn"
	end

	local pnpmlock = string.format("%s/pnpm-lock.yaml", vim.loop.cwd())
	if vim.fn.filereadable(pnpmlock) == 1 then
		return "pnpm"
	end

	return "npm"
end

M.err = {}

function M.err.writeln(msg)
	vim.api.nvim_notify(string.format("[web.nvim] %s", msg), vim.log.levels.WARN, {})
end

function M.warn(msg)
	vim.api.nvim_notify(string.format("web.nvim: %s", msg), vim.log.levels.WARN, {})
end

return M
