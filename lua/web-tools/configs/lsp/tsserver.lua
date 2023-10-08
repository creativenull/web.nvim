local utils = require("web-tools.utils")
local M = {}

M.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
M.root_dirs = { "tsconfig.json", "jsconfig.json" }
M.on_attach = function(client, bufnr) end

function M.lsp_config(tsserver_opts)
	local inlay_hints = false
	if tsserver_opts.inlay_hints then
		inlay_hints = true
	end

	return {
		name = "tsserver",
		cmd = { "typescript-language-server", "--stdio" },
		root_dir = vim.fs.dirname(vim.fs.find(M.root_dirs, { upward = true })[1]),
		init_options = { hostInfo = utils.host_info() },
		settings = {
			javascript = {
				inlayHints = {
					includeInlayEnumMemberValueHints = inlay_hints,
					includeInlayFunctionLikeReturnTypeHints = inlay_hints,
					includeInlayFunctionParameterTypeHints = inlay_hints,
					includeInlayParameterNameHints = inlay_hints and "all" or "none",
					includeInlayParameterNameHintsWhenArgumentMatchesName = inlay_hints,
					includeInlayPropertyDeclarationTypeHints = inlay_hints,
					includeInlayVariableTypeHints = inlay_hints,
					includeInlayVariableTypeHintsWhenTypeMatchesName = inlay_hints,
				},
			},
			typescript = {
				inlayHints = {
					includeInlayEnumMemberValueHints = inlay_hints,
					includeInlayFunctionLikeReturnTypeHints = inlay_hints,
					includeInlayFunctionParameterTypeHints = inlay_hints,
					includeInlayParameterNameHints = inlay_hints and "all" or "none",
					includeInlayParameterNameHintsWhenArgumentMatchesName = inlay_hints,
					includeInlayPropertyDeclarationTypeHints = inlay_hints,
					includeInlayVariableTypeHints = inlay_hints,
					includeInlayVariableTypeHintsWhenTypeMatchesName = inlay_hints,
				},
			},
		},
	}
end

return M
