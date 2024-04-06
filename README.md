# web.nvim

The all-in-one solution to setup a web development environment in neovim.

## Features

- No [`lspconfig` plugin][lspconfig-url] needed, we use builtin `vim.lsp.start()`
- Automatically setup lsp servers based on project (tsserver, eslint, WIP: css, html, volar, svelte, astrojs)
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
- Run `package.json` scripts via `:WebRun` (WIP)
- Debugging: [nvim-dap][nvim-dap-url] is required (WIP)

[lspconfig-url]: https://github.com/neovim/nvim-lspconfig
[mason-url]: https://github.com/williamboman/mason.nvim
[nvim-dap-url]: https://github.com/mfussenegger/nvim-dap
