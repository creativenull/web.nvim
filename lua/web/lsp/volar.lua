local event = require("web.event")
local utils = require("web.utils")
local M = {}

local _name = "vue-lsp"
local _cmd = { "vue-language-server", "--stdio" }

M.filetypes = { "vue" }
M.root_dirs = { "vue.config.js", "vue.config.ts", "nuxt.config.js", "nuxt.config.ts" }

local function get_project_tsserverjs()
  local project_path = utils.fs.find_nearest({ "node_modules" })
  if project_path == nil then
    return nil
  end

  local path = string.format("%s/node_modules/typescript/lib", project_path)
  if vim.fn.isdirectory(path) == 0 then
    return nil
  end

  return path
end

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.err.writeln(string.format("%s: Command not found. Check :help web-vue-lsp for more info.", _cmd[1]))
    return false
  end

  return true
end

local function _config(on_attach, capabilities, lspconfig)
  return {
    name = _name,
    cmd = _cmd,
    on_attach = on_attach,
    capabilities = capabilities,
    root_dir = utils.fs.find_nearest(M.root_dirs),
    init_options = {
      typescript = { tsdk = get_project_tsserverjs() },
      vue = { hybridMode = true },
    },
  }
end

function M.set_user_commands(bufnr) end

function M.setup(opts)
  vim.api.nvim_create_autocmd("FileType", {
    desc = string.format("web.nvim: start %s", _name),
    group = event.group(_name),
    pattern = M.filetypes,
    callback = function(ev)
      if not _validate() then
        return
      end

      vim.lsp.start(_config(opts.on_attach, opts.capabilities, opts.lsp.volar))
      M.set_user_commands(ev.buf)
    end,
  })
end

return M
