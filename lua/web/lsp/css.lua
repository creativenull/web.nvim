local utils = require("web.utils")
local event = require("web.event")
local M = {}

local _name = "css_ls"
local _cmd = { "vscode-css-language-server", "--stdio" }

M.filetypes = { "css", "sccs", "sass", "less" }
M.root_dirs = { "package.json" }
M.capabilities = vim.lsp.protocol.make_client_capabilities()

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.report_error(string.format("%s: Command not found. Check :help web-css-lsp for more info.", _cmd[1]))
    return false
  end

  return true
end

local function _config(css_options, user_options)
  if user_options.capabilities then
    M.capabilities = user_options.capabilities
  end

  return {
    name = _name,
    cmd = _cmd,
    on_attach = user_options.on_attach,
    capabilities = M.capabilities,
    root_dir = utils.fs.find_nearest(M.root_dirs),
    settings = {
      css = {
        validate = true,
        completion = { triggerPropertyValueCompletion = true, completePropertyWithSemicolon = true },
        lint = { validProperties = {} },
      },
      scss = {
        validate = true,
        completion = { triggerPropertyValueCompletion = true, completePropertyWithSemicolon = true },
        lint = { validProperties = {} },
      },
      less = {
        validate = true,
        completion = { triggerPropertyValueCompletion = true, completePropertyWithSemicolon = true },
        lint = { validProperties = {} },
      },
    },
  }
end

function M.set_user_commands(bufnr) end

function M.setup(user_options)
  vim.api.nvim_create_autocmd("FileType", {
    desc = string.format("web.nvim: start %s", _name),
    group = event.group(_name),
    pattern = M.filetypes,
    callback = function(ev)
      if not _validate() then
        return
      end

      vim.lsp.start(_config(user_options.lsp.css, user_options))
      M.set_user_commands(ev.buf)
    end,
  })
end

return M
