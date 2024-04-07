local M = {}

function M.group(suffix)
	suffix = suffix or "core"
	return vim.api.nvim_create_augroup(string.format("web_tools_%s_group", suffix), {})
end

return M
