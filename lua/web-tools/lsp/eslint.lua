local utils = require("web-tools.utils")
local event = require("web-tools.event")
local M = {}

M.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
M.root_dirs = { ".eslintrc", ".eslintrc.cjs", ".eslintrc.js", ".eslintrc.json", ".eslintrc.yaml", ".eslintrc.yml" }
M.on_attach = function(_, _) end

local cmd = "vscode-eslint-language-server"

local function validated()
	if vim.fn.executable(cmd) == 0 then
		utils.err.writeln(string.format("%s: Command not found. Check :help web-tools-eslint-lsp for more info.", cmd))
		return false
	end

	return true
end

local function config(eslint_opts)
	return {
		name = "eslint",
		cmd = { cmd, "--stdio" },
		on_attach = M.on_attach,
		root_dir = utils.fs.find_nearest(M.root_dirs),
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
			format = { enable = true },
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
	vim.api.nvim_buf_create_user_command(bufnr, "WebEslintFixAll", function(usr_cmd)
		vim.lsp.buf.code_action({
			context = { only = { "source.fixAll.eslint" }, triggerKind = 1 },
			apply = true,
			range = {
				["start"] = { usr_cmd.line1, 0 },
				["end"] = { usr_cmd.line2, 0 },
			},
		})
	end, { range = true })
end

local function ensure_root_file()
	for _, root_file in pairs(M.root_dirs) do
		local filepath = string.format("%s/%s", vim.loop.cwd(), root_file)
		if vim.fn.filereadable(filepath) == 1 then
			return true
		end
	end

	return false
end

function M.setup(opts)
	if not ensure_root_file() then
		return
	end

	vim.api.nvim_create_autocmd("FileType", {
		desc = "web-tools: start eslint lsp server and client",
		group = event.group("eslint"),
		pattern = M.filetypes,
		callback = function(ev)
			if not validated() then
				return
			end

			M.on_attach = opts.on_attach
			vim.lsp.start(config(opts.lsp.eslint))
			M.register_commands(ev.buf)
		end,
	})
end

return M
