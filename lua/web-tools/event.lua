local M = {}

function M.group()
	return vim.api.nvim_create_augroup("WebToolsGroup", {})
end

return M
