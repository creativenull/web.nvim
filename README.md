# web.nvim

The all-in-one solution to setup a web development environment in neovim.

> [!IMPORTANT]
> Currently under active development, please don't use this as your daily driver yet.

## Features

- No [`lspconfig` plugin][lspconfig-url] needed, we use builtin `vim.lsp.start()`
- Automatically setup lsp servers based on project (tsserver, eslint, css, html, WIP: volar, svelte, astrojs)
- Automatically setup formatters (prettier, WIP: biomejs)
- Format code - `:WebLspFormat`, and option to format on save
- Run code actions on save feature
- Refactor code - `:WebRefactorAction`
- Quickfix code - `:WebQuickfixAction`
- Source action - `:WebSourceAction`
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
  config = function()
    -- ...
  end,
}
```

## Setup

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

[lspconfig-url]: https://github.com/neovim/nvim-lspconfig
[mason-url]: https://github.com/williamboman/mason.nvim
[nvim-dap-url]: https://github.com/mfussenegger/nvim-dap
