# web-tools.nvim

The all-in-one solution to setup a web development environment in neovim.

## Features

- No [`lspconfig` plugin][lspconfig-url] needed, we use builtin `vim.lsp.start()`
- Automatically setup lsp servers based on filetype (similar to `lspconfig`), supports [`mason.nvim`][mason-url] if present
  - `tsserver`
- Run `package.json` scripts via `:WebToolsRun`
- Refactor code with `:WebToolsRefactorAction`
- Quickfix code with `:WebToolsQuickfixAction`
- Code actions on save
- Debugging: [nvim-dap][nvim-dap-url] is required

[lspconfig-url]: https://github.com/neovim/nvim-lspconfig
[mason-url]: https://github.com/williamboman/mason.nvim
[nvim-dap-url]: https://github.com/mfussenegger/nvim-dap
