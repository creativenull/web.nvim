local M = {}

function M.register_common_user_commands(bufnr)
	vim.api.nvim_buf_create_user_command(bufnr, "WebQuickfixAction", function(usr_cmd)
		vim.lsp.buf.code_action({
			context = { only = { "quickfix" }, triggerKind = 1 },
			range = {
				["start"] = { usr_cmd.line1, 0 },
				["end"] = { usr_cmd.line2, 0 },
			},
		})
	end, { range = true })

	vim.api.nvim_buf_create_user_command(bufnr, "WebRefactorAction", function(cmd)
		vim.lsp.buf.code_action({
			context = { only = { "refactor" }, triggerKind = 1 },
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })

	vim.api.nvim_buf_create_user_command(bufnr, "WebSourceAction", function(cmd)
		vim.lsp.buf.code_action({
			context = { only = { "source" }, triggerKind = 1 },
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })
end

return M
