local utils = require("web.utils")
local event = require("web.event")
local M = {}

local _name = "html_ls"
local _cmd = { "vscode-html-language-server", "--stdio" }

M.filetypes = { "html" }
M.root_dirs = { "package.json" }
M.capabilities = vim.lsp.protocol.make_client_capabilities()

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.report_error(string.format("%s: Command not found. Check :help web-html-lsp for more info.", _cmd[1]))
    return false
  end

  return true
end

local function _config(html_options, user_options)
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
      html = { validate = { scripts = true, styles = true } },
      css = {
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


      -- TODO: find a way to avoid this situation, if possible
      if vim.endswith(ev.file, ".html") then
        -- Only start the html server on html files and not just
        -- on files that get inherited by the html syntax
        vim.lsp.start(_config(user_options.lsp.html, user_options))
        M.set_user_commands(ev.buf)
      end
    end,
  })
end

return M
