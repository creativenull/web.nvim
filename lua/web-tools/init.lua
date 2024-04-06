local lsp_shared = require("web-tools.lsp._shared")
local event = require("web-tools.event")
local validator = require("web-tools.validator")
local M = {}

local default_setup_opts = {
	on_attach = nil,
	format_on_save = false,

	lsp = {
		tsserver = {
			-- Inlay hints are opt-out feature in nvim >= v0.10
			-- which means they will be enabled by default from v0.10 and onwards
			inlay_hints = vim.fn.has("nvim-0.10") == 1,

			-- TODO: wait for nvim PR to be stable/merged (https://github.com/neovim/neovim/pull/22598)
			code_actions_on_save = {
				"source.organizeImports.ts",
				"source.fixAll.ts",
				"source.removeUnused.ts",
				"source.addMissingImports.ts",
				"source.removeUnusedImports.ts",
				"source.sortImports.ts",
			},
		},

		eslint = {
			workspace = true,
			flat_config = false,
			code_actions_on_save = {
				"source.fixAll.eslint",
			},
		},
	},
}

function M.setup(setup_opts)
	local valid, mod = pcall(validator.validate_requirements)
	if not valid then
		vim.api.nvim_err_writeln(mod)
		return
	end

	if type(setup_opts) == "table" then
		setup_opts = vim.tbl_extend("force", default_setup_opts, setup_opts)
	else
		setup_opts = default_setup_opts
	end

	if setup_opts.lsp.tsserver then
		require("web-tools.lsp.tsserver").setup(setup_opts)
	end

	if setup_opts.lsp.eslint then
		require("web-tools.lsp.eslint").setup(setup_opts)
	end

	vim.api.nvim_create_autocmd("LspAttach", {
		group = event.group("default"),
		callback = function(ev)
			local bufnr = ev.buf
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			vim.print("We attached: " .. client.name)

			lsp_shared.register_common_user_commands(bufnr)
		end,
	})
end

return M
