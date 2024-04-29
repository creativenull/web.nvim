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

	--[[
  Astro Project
    - Detect project
    - Register autocmd to run lsp servers with options
  --]]
  if detected(require('web.lsp.astro').root_dirs) then
    require('web.lsp.astro').setup(setup_opts)
    require('web.lsp.tsserver').setup(setup_opts)

    return
  end

	--[[
  Svelte Project
    - Detect project
    - Register autocmd to run lsp servers with options
  --]]
  if detected(require('web.lsp.svelte').root_dirs) then
    require('web.lsp.svelte').setup(setup_opts)
    require('web.lsp.tsserver').setup(setup_opts)

    if detected(require('web.lsp.eslint').root_dirs) then
      require('web.lsp.eslint').setup(setup_opts, { 'svelte' })
    end

    return
  end

	--[[
  Vue Project
    - Detect project
    - Register autocmd to run lsp servers with options
  --]]
  if detected(require('web.lsp.volar').root_dirs) then
    require('web.lsp.volar').setup(setup_opts)

    -- Setup tsserver with vue support
    local location = ''
    local is_mason = pcall(require, 'mason')

    if is_mason then
      location = string.format('%s/node_modules/@vue/language-server',  require('mason-registry').get_package('vue-language-server'):get_install_path())
    else
      local result = vim.fn.systemlist('npm ls -g --depth=0')
      if result == '' then
        utils.warn('nodejs not installed in your machine')

        return
      end

      location = string.format('%s/node_modules/@vue/language-server', result[1])
    end

    require('web.lsp.tsserver').setup(setup_opts, { 'vue' }, {
      plugins = {
        { name = '@vue/typescript-plugin', location = location, languages = { 'vue' } },
      },
    })

    -- Eslint support
    if detected(require('web.lsp.eslint').root_dirs) then
      require('web.lsp.eslint').setup(setup_opts, { 'vue' })
    end

    return
  end

	--[[
  TS/JS Project
    - Detect project
    - Register autocmd to run lsp servers with options
  --]]
  if detected(require('web.lsp.tsserver').root_dirs) then
    require('web.lsp.tsserver').setup(setup_opts)

    if detected(require('web.lsp.eslint').root_dirs) then
      require('web.lsp.eslint').setup(setup_opts)
    end

    return
  end
end

M.format = require("web.format")

return M
