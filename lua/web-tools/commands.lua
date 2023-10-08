local diagnostic = require("web-tools.diagnostic")

local M = {}

function M.register(opts)
  --[[
	vim.api.nvim_create_user_command("WebToolsCommand", function(cmd)
		local bufnr = vim.api.nvim_get_current_buf()
		if cmd.args then
			if cmd.args == "organizeImports" then
				vim.lsp.buf.execute_command({
					command = string.format("_typescript.%s", cmd.args),
					arguments = { vim.api.nvim_buf_get_name(bufnr) },
				})
			end
		end
	end, {
		complete = function()
			return opts.tsserver.commands
		end,
		nargs = 1,
		range = true,
	})

	vim.api.nvim_create_user_command("WebToolsRefactorAction", function(cmd)
		vim.lsp.buf.code_action({
			context = { only = { "refactor" }, triggerKind = 1 },
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })

	vim.api.nvim_create_user_command("WebToolsQuickfixAction", function(cmd)
		vim.lsp.buf.code_action({
			context = { only = { "quickfix" }, triggerKind = 1 },
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })

	vim.api.nvim_create_user_command("WebToolsSourceAction", function(cmd)
		vim.lsp.buf.code_action({
			context = { only = { "source" }, triggerKind = 1 },
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })

	vim.api.nvim_create_user_command("WebToolsCodeAction", function(cmd)
		vim.lsp.buf.code_action({
			range = {
				["start"] = { cmd.line1, 0 },
				["end"] = { cmd.line2, 0 },
			},
		})
	end, { range = true })

	vim.api.nvim_create_user_command("WebToolsCodeActionsOnSave", function(cmd)
		local client = vim.lsp.get_active_clients({ name = "tsserver", bufnr = vim.api.nvim_get_current_buf() })
		client = #client == 1 and client[1] or nil
		if not client then
			return
		end

		local function apply_source_code_action(source)
			local params = vim.tbl_extend("force", vim.lsp.util.make_range_params(), {
				context = {
					diagnostics = diagnostic.vim_to_lsp(vim.diagnostic.get()),
					only = { source },
				},
			})

			local response = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
			if #response == 1 then
				response = response[1]
			end

			if response.result then
				local action = #response.result == 1 and response.result[1] or nil

				if action then
					if type(action.edit) == "table" and not vim.tbl_isempty(action.edit) then
						vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
						vim.loop.sleep(700)
					end
				end
			end
		end

    vim.print("Applying code actions on save")
		for _, source in pairs(opts.tsserver.code_actions_on_save) do
			-- apply_source_code_action(source)
      vim.lsp.buf.code_action({ context = { only = { source }, triggerKind = 2 }, apply = true })
		end
	end, {})
  --]]
end

return M
