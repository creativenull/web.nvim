# web.nvim

The all-in-one solution to setup a web development environment in neovim.

> [!IMPORTANT]
> Still under development but feel free to use and give feedback on anything missing.

## Features

- No [`lspconfig` plugin][lspconfig-url] needed, using builtin `vim.lsp.start()`
- Automatically setup lsp servers based on project (tsserver, eslint, css, html, vue, svelte, astrojs, tailwindcss, WIP: angularls)
- Automatically setup formatters (prettier, WIP: biomejs)
- Format code - `:WebLspFormat`, additional set the `format_on_save` option to format on save
- Run code actions on save feature (WIP)
- Refactor code - `:WebRefactorAction`
- Quickfix code - `:WebQuickfixAction`
- Source action - `:WebSourceAction`
- Inlay hints (if using nvim 0.10 and above, opt-out feature)
- Tsserver specific
  - Organize imports - `:WebTsserverOrganizeImports`
  - Go to source definition, helpful when you do not want d.ts but direct to source file (for example, go to .js file instead of d.ts definition) - `:WebTsserverGoToSourceDefinition`
- Eslint specific
  - Fix eslint errors - `:WebEslintFixAll`
- Run `package.json` scripts via `:WebRun`
- Debugging: [nvim-dap][nvim-dap-url] is required (WIP)

## Install

### vim-plug

```vimscript
Plug 'creativenull/web.nvim'
```


### lazy.nvim

```lua
{
  'creativenull/web.nvim',
  opts = {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    on_attach = function(client, bufnr)
      -- ...
    end,
  },
}
```

## Setup

You can setup the plugin using the following the minimal code example.

```lua
-- You can use that exact same on_attach you have already defined for lspconfig
-- or create one like below
local on_attach = function(client, bufnr)
  -- ...
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

require('web').setup({
  on_attach = on_attach,
  capabilities = capabilities,
})
```

Following is the code example with all the settings, to show all the options and
their default values.

```lua
-- You can use that exact same on_attach you have already defined for lspconfig
-- or create one like below
local on_attach = function(client, bufnr)
  -- ...
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

require('web').setup({
  on_attach = on_attach,
  capabilities = capabilities,

  -- Format the buffer using formatting tools prettier and biomejs (WIP), if available
  format_on_save = false,

  -- LSP Server settings
  lsp = {
    json = { disabled = false },

    css = { disabled = false },

    html = { disabled = false },

    -- Astro LSP settings
    astro = {
      disabled = false,
      inlay_hints = vim.fn.has("nvim-0.10") == 1 and "minimal" or "",
    },

    -- Vue LSP settings
    vue = {
      disabled = false,
      inlay_hints = vim.fn.has("nvim-0.10") == 1,
    },

    -- Svelte LSP settings
    svelte = {
      disabled = false,
      inlay_hints = vim.fn.has("nvim-0.10") == 1 and "minimal" or "",
    },

    -- JS/TS Server LSP settings
    tsserver = {
      disabled = false,

      -- Enable the minimal option of inlay hints if runnning on nvim 0.10 or above
      inlay_hints = vim.fn.has("nvim-0.10") == 1 and "minimal" or "",

      -- Code actions to run on save, not implemented yet
      -- Waiting for this PR to be stable/merged (https://github.com/neovim/neovim/pull/22598)
      code_actions_on_save = {
        "source.organizeImports.ts",
        "source.fixAll.ts",
        "source.removeUnused.ts",
        "source.addMissingImports.ts",
        "source.removeUnusedImports.ts",
        "source.sortImports.ts",
      },
    },

    -- Eslint LSP settings
    eslint = {
      disabled = false,
      workspace = true,
      flat_config = false,
      code_actions_on_save = {
        "source.fixAll.eslint",
      },
    },

    -- Tailwind CSS LSP settings
    tailwindcss = {
      disabled = false,
      additional_filetypes = nil,
    },
  },
})
```

### Capabilities

If using nvim-cmp or similar that provide you with custom capabilities, then you
can use that. For example:

```lua
local capabilities = require('cmp_nvim_lsp').default_capabilities()
```

Or if you have a custom completion plugin that doesn't come with that support
then use the following:

```lua
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Let LSP server know you support snippets too
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.preselectSupport = true
capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  },
}
```

## Notes

### Vue language server (difference between v2 and v3)

#### v3

Since the release of vue-language-server v3, the language server now requires vtsls server to be installed as an
additional dependency. Ensure that you have it installed via Mason.nvim or with `npm install -g @vtsls/language-server`.

#### v2

If you decide to stick with v2 of the vue language server, then you don't have to do anything as this is not being
phased out. Plan is to phase it out if v4 of the language server is released.

However, you are having issues like `Invalid 'col': out of range` then it's most likely a inlay hints issue and I
suggest to set `inlay_hints = false` for now.

```lua
vue = {
  inlay_hints = false,
}
```

[lspconfig-url]: https://github.com/neovim/nvim-lspconfig
[mason-url]: https://github.com/williamboman/mason.nvim
[nvim-dap-url]: https://github.com/mfussenegger/nvim-dap
