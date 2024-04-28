local utils = require("web.utils")
local lsp_shared = require("web.lsp._shared")
local validator = require("web.validator")
local M = {}

local function register_plugin_cmds()
	require("web.run").setup()
end

local function create_common_on_attach(user_on_attach)
	return function(client, bufnr)
		user_on_attach(client, bufnr)
		lsp_shared.register_lsp_cmds(bufnr)
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

local function detected(root_files)
	return utils.fs.find_nearest(root_files) ~= nil
end

function M.setup(setup_opts)
	local valid, mod = pcall(validator.validate_requirements)
	if not valid then
		vim.api.nvim_err_writeln(mod)
		return
	end

	if setup_opts ~= nil and type(setup_opts) == "table" then
		setup_opts = vim.tbl_extend("force", default_setup_opts, setup_opts)
	else
		setup_opts = default_setup_opts
	end

	setup_opts.on_attach = create_common_on_attach(setup_opts.on_attach)

  -- Register any non-lsp dependent features
	register_plugin_cmds()

	-- Detect if a project or a monorepo

	--[[
  Astro Project
    - Detect project
    - Register autocmd to run lsp servers with options
  --]]
  if detected({ 'astro.config.js', 'astro.config.ts' }) then
    require('web.lsp.astro').setup(setup_opts)
    require('web.lsp.tsserver').setup(setup_opts)

    return
  end

	--[[
  Svelte Project
    - Detect project
    - Register autocmd to run lsp servers with options
  --]]
  if detected({ 'svelte.config.js', 'svelte.config.ts' }) then
    require('web.lsp.svelte').setup(setup_opts)
    require('web.lsp.tsserver').setup(setup_opts)

    if detected({ '.eslintrc', '.eslintrc.js', '.eslintrc.ts', 'eslint.config.js', 'eslint.config.ts' }) then
      require('web.lsp.eslint').setup(setup_opts, { 'svelte' })
    end

    return
  end

	--[[
  Vue Project
    - Detect project
    - Register autocmd to run lsp servers with options
  --]]

	--[[
  TS/JS Project
    - Detect project
    - Register autocmd to run lsp servers with options
  --]]
end

M.format = require("web.format")

return M
