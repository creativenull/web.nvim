local event = require("web.event")
local utils = require("web.utils")
local M = {}

local _name = "language-server-name"
local _cmd = { "language-server-binary", "--stdio" }

M.filetypes = {}
M.root_dirs = {}

local function _validate() end

local function _config(options, user_options)
  return {
    name = _name,
    cmd = _cmd,
    on_attach = user_options.on_attach,
    capabilities = user_options.capabilities,
    root_dir = utils.fs.find_nearest(M.root_dirs),
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

      -- vim.lsp.start(_config(user_options.lsp.<>, user_options))
      -- M.set_user_commands(ev.buf)
    end,
  })
end

return M
