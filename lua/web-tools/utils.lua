local M = {}

function M.host_info()
	local ver = vim.version()
	return string.format("NVIM v%d.%d.%d", ver.major, ver.minor, ver.patch)
end

return M
