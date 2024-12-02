local utils = require("web.utils")
local event = require("web.event")
local M = {}

local _name = "eslint_ls"
local _cmd = { "vscode-eslint-language-server", "--stdio" }

M.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
M.root_dirs = {
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.ts",
  ".eslintrc",
  ".eslintrc.cjs",
  ".eslintrc.mjs",
  ".eslintrc.js",
  ".eslintrc.ts",
  ".eslintrc.json",
  ".eslintrc.yaml",
  ".eslintrc.yml",
}

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.report_error(string.format("%s: Command not found. Check :help web-eslint-lsp for more info.", _cmd[1]))
    return false
  end

  return true
end

local function _config(eslint_options, user_options)
  return {
    name = _name,
    cmd = _cmd,
    on_attach = user_options.on_attach,
    root_dir = utils.fs.find_nearest(M.root_dirs),
    settings = {
      -- ref: https://github.com/neovim/nvim-lspconfig/blob/d0cdbae787cabff3574ec80b119bbd412333fb78/lua/lspconfig/server_configurations/eslint.lua#L65
      validate = "on",
      packageManager = nil,
      useESLintClass = false,
      experimental = { useFlatConfig = eslint_options.flat_config },
      codeActionOnSave = {
        enable = false,
        mode = "all",
      },
      format = true,
      quiet = false,
      onIgnoredFiles = "off",
      rulesCustomizations = {},
      run = "onType",
      problems = { shortenToSingleLine = false },
      -- nodePath configures the directory in which the eslint server should start its node_modules resolution.
      -- This path is relative to the workspace folder (root dir) of the server instance.
      nodePath = "",
      -- use the workspace folder location or the file location (if no workspace folder is open) as the working directory
      workingDirectory = { mode = "location" },
      codeAction = {
        disableRuleComment = {
          enable = true,
          location = "separateLine",
        },
        showDocumentation = { enable = true },
      },
    },
  }
end

function M.set_user_commands(bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, "WebEslintFixAll", function(usr_cmd)
    vim.lsp.buf.code_action({
      context = { only = { "source.fixAll.eslint" }, triggerKind = 1 },
      apply = true,
      range = {
        ["start"] = { usr_cmd.line1, 0 },
        ["end"] = { usr_cmd.line2, 0 },
      },
    })
  end, { range = true })
end

function M.setup(user_options, lsp_config)
  if lsp_config and lsp_config.filetypes then
    vim.list_extend(M.filetypes, lsp_config.filetypes)
  end

  vim.api.nvim_create_autocmd("FileType", {
    desc = string.format("web.nvim: start %s", _name),
    group = event.group(_name),
    pattern = M.filetypes,
    callback = function(ev)
      if not _validate() then
        return
      end

      vim.lsp.start(_config(user_options.lsp.eslint, user_options))
      M.set_user_commands(ev.buf)
    end,
  })
end

return M
