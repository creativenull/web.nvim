local utils = require("web.utils")
local event = require("web.event")
local M = {}

M.filetypes = { "css", "sccs", "sass", "less" }
M.root_dirs = { "package.json" }
M.on_attach = function(_, _) end
M.capabilities = vim.lsp.protocol.make_client_capabilities()

local cmd = "vscode-css-language-server"

local function validated()
  if vim.fn.executable(cmd) == 0 then
    utils.err.writeln(string.format("%s: Command not found. Check :help web-css-lsp for more info.", cmd))
    return false
  end

  return true
end

local function config(opts)
  return {
    name = "css-lsp",
    cmd = { cmd, "--stdio" },
    on_attach = M.on_attach,
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

function M.register_commands(bufnr) end

function M.setup(opts)
  vim.api.nvim_create_autocmd("FileType", {
    desc = "web: start css lsp server and client",
    group = event.group("css"),
    pattern = M.filetypes,
    callback = function(ev)
      if not validated() then
        return
      end

      M.on_attach = opts.on_attach

      if opts.capabilities then
        M.capabilities = opts.capabilities
      end

      vim.lsp.start(config(opts.lsp.css))
      M.register_commands(ev.buf)
    end,
  })
end

return M
