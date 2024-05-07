local lsp_shared = require("web.lsp._shared")
local event = require("web.event")
local utils = require("web.utils")
local M = {}

local _name = "astro_ls"
local _cmd = { "astro-ls", "--stdio" }

M.filetypes = { "astro", "markdown" }
M.root_dirs = { "astro.config.js", "astro.config.ts", "astro.config.cjs", "astro.config.mjs" }

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.err.writeln(string.format("%s: Command not found. Check :help web-astro-lsp for more info.", _cmd[1]))
    return false
  end

  local is_global = vim.fn.executable("tsc") == 1
  if not is_global and lsp_shared.get_project_tslib() == "" then
    utils.err.writeln(
      "Typescript not installed in project, run `npm install -D typescript`. Check :help web-astro-tsc for more info."
    )
    return false
  end

  return true
end

local function _config(astro_options, user_options)
  return {
    name = _name,
    cmd = _cmd,
    on_attach = user_options.on_attach,
    init_options = {
      typescript = { tsdk = lsp_shared.get_project_tslib() },
    },
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

      vim.lsp.start(_config(user_options.lsp.astro, user_options))
      M.set_user_commands(ev.buf)
    end,
  })
end

return M
