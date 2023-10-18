local event = require("web-tools.event")
local utils = require("web-tools.utils")
local M = {}

M.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
M.root_dirs = { "tsconfig.json", "jsconfig.json" }
M.on_attach = function(_, _) end

local function config(tsserver_opts)
	local inlay_hints = false
	if tsserver_opts.inlay_hints then
		inlay_hints = true
	end

	return {
		name = "tsserver",
		cmd = { "typescript-language-server", "--stdio" },
		on_attach = M.on_attach,
		root_dir = vim.fs.dirname(vim.fs.find(M.root_dirs, { upward = true })[1]),
		init_options = {
			hostInfo = utils.host_info(),
			tsserver = {
				path = string.format(
					"%s/node_modules/typescript/lib/tsserver.js",
					vim.fs.dirname(vim.fs.find({ "node_modules" }, { upward = true })[1])
				),
			},
		},
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

function M.register_commands(bufnr)
	vim.api.nvim_buf_create_user_command(bufnr, "WebToolsTsserverRefactorAction", function(cmd)
		vim.lsp.buf.code_action({
			context = { only = { "refactor" }, triggerKind = 1 },
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })

	vim.api.nvim_buf_create_user_command(bufnr, "WebToolsTsserverQuickfixAction", function(cmd)
		vim.lsp.buf.code_action({
			context = { only = { "quickfix" }, triggerKind = 1 },
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })

	vim.api.nvim_buf_create_user_command(bufnr, "WebToolsTsserverSourceAction", function(cmd)
		vim.lsp.buf.code_action({
			context = { only = { "source" }, triggerKind = 1 },
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })

	vim.api.nvim_buf_create_user_command(bufnr, "WebToolsTsserverAllActions", function(cmd)
		vim.lsp.buf.code_action({
			context = { only = { "source", "quickfix", "refactor" }, triggerKind = 1 },
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })
end

function M.register_events(opts)
	vim.api.nvim_create_autocmd("FileType", {
		desc = "web-tools: start tsserver lsp server and client",
		group = event.group(),
		pattern = M.filetypes,
		callback = function(ev)
			M.on_attach = opts.on_attach
			vim.lsp.start(config(opts.lsp.tsserver))
			M.register_commands(ev.buf)
		end,
	})
end

function M.setup(opts)
	M.register_events(opts)
end

return M
