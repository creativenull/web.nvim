local commands = require("web-tools.commands")
local events = require("web-tools.events")
local validator = require("web-tools.validator")

local M = {}

local default_setup_opts = {
	on_attach = nil,
	format_on_save = false,

	lsp = {
		tsserver = {
			workspaces = true,

			-- Inlay hints are opt-out feature in nvim v0.10.*
			-- which means they are enabled by default from v0.10 and onwards
			inlay_hints = vim.fn.has("nvim-0.10") == 1,

			code_actions_on_save = {
				"source.organizeImports.ts",
				"source.fixAll.ts",
				"source.removeUnused.ts",
				"source.addMissingImports.ts",
				"source.removeUnusedImports.ts",
				"source.sortImports.ts",
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

	events.register(setup_opts)
	commands.register(setup_opts)
end

return M
