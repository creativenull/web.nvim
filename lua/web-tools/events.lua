local M = {}

function M.group()
	return vim.api.nvim_create_augroup("WebToolsGroup", {})
end

function M.register_tsserver(opts)
	local tsserver = require("web-tools.configs.lsp.tsserver")

	vim.api.nvim_create_autocmd("FileType", {
		desc = "web-tools: start tsserver lsp server and client",
		group = M.group(),
		pattern = tsserver.filetypes,
		callback = function()
      tsserver.on_attach = opts.on_attach
			vim.lsp.start(tsserver.lsp_config(opts.lsp.tsserver))
		end,
	})
end

function M.register(opts)
	M.register_tsserver(opts)
end

return M
