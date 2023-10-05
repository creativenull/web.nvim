# web-tools.nvim

The all-in-one solution to setup a web development environment in neovim.

## Features

- No `lspconfig` plugin needed, we use builtin `vim.lsp.start()`
- Automatically setup lsp servers based on filetype (similar to `lspconfig`), supports `mason.nvim` if present
  - `tsserver`
  - `@volar/vue-language-server`
  - `@astrojs/language-server`
  - `svelte-language-server`
  - and more
- Workspaces aka monorepo support
  - npm
  - yarn
  - pnpm
  - and more
- Run `package.json` scripts via `:WebToolsRun`
- Refactor code with `:WebToolsRefactorAction`
- Quickfix code with `:WebToolsQuickfixAction`
- Code actions on save
- Debugging: [nvim-dap][nvim-dap-url] is required

[nvim-dap-url]: https://github.com/mfussenegger/nvim-dap
