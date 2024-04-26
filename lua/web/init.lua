local lsp_shared = require("web.lsp._shared")
local validator = require("web.validator")
local M = {}

local function register_plugin_cmds()
	require("web.run").setup()
end

local function create_common_on_attach(user_on_attach)
	return function(bufnr, client)
		lsp_shared.register_lsp_cmds(bufnr)
		user_on_attach(bufnr, client)
	end
end

local default_setup_opts = {
	on_attach = nil,
	capabilities = nil,
	format_on_save = false,

	lsp = {
		css = {},
		html = {},
		astro = {},
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

	setup_opts.on_attach = create_common_on_attach(setup_opts.on_attach)

	-- Svelte Project

	-- Astro Project

	-- Vue Project

	-- TS/JS Project

	register_plugin_cmds()
end

M.format = require("web.format")

return M
