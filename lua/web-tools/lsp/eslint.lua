local event = require("web-tools.event")
local M = {}

M.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
M.root_dirs = {
	".eslintrc",
	".eslintrc.cjs",
	".eslintrc.js",
	".eslintrc.json",
	".eslintrc.yaml",
	".eslintrc.yml",
	"package.json",
}

M.on_attach = function(_, _) end

local function config(eslint_opts)
	return {
		name = "eslint",
		cmd = { "vscode-eslint-language-server", "--stdio" },
		on_attach = M.on_attach,
		root_dir = vim.fs.dirname(vim.fs.find(M.root_dirs, { upward = true })[1]),
		settings = {
			-- ref: https://github.com/neovim/nvim-lspconfig/blob/d0cdbae787cabff3574ec80b119bbd412333fb78/lua/lspconfig/server_configurations/eslint.lua#L65
			validate = "on",
			packageManager = nil,
			useESLintClass = false,
			experimental = { useFlatConfig = eslint_opts.flat_config },
			codeActionOnSave = {
				enable = false,
				mode = "all",
			},
			format = true,
			quiet = false,
			onIgnoredFiles = "off",
			rulesCustomizations = {},
			run = "onType",
			problems = { shortenToSingleLine = false },
			-- nodePath configures the directory in which the eslint server should start its node_modules resolution.
			-- This path is relative to the workspace folder (root dir) of the server instance.
			nodePath = "",
			-- use the workspace folder location or the file location (if no workspace folder is open) as the working directory
			workingDirectory = { mode = "location" },
			codeAction = {
				disableRuleComment = {
					enable = true,
					location = "separateLine",
				},
				showDocumentation = { enable = true },
			},
		},
	}
end

function M.register_commands(bufnr)
	vim.api.nvim_buf_create_user_command(bufnr, "WebEslintQuickfixAction", function(cmd)
		vim.lsp.buf.code_action({
			context = { only = { "quickfix" }, triggerKind = 1 },
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })

	vim.api.nvim_buf_create_user_command(bufnr, "WebEslintSourceAction", function(cmd)
		vim.lsp.buf.code_action({
			context = { only = { "source.fixAll.eslint" }, triggerKind = 1 },
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })
end

function M.register_events(opts)
	vim.api.nvim_create_autocmd("FileType", {
		desc = "web-tools: start eslint lsp server and client",
		group = event.group("eslint"),
		pattern = M.filetypes,
		callback = function(ev)
			M.on_attach = opts.on_attach
			vim.lsp.start(config(opts.lsp.eslint))
			M.register_commands(ev.buf)
		end,
	})
end

function M.setup(opts)
	M.register_events(opts)
end

return M
