local event = require("web.event")
local utils = require("web.utils")
local M = {}

M.filetypes = { "astro" }
M.root_dirs = { "astro.config.js", "astro.config.ts", "astro.config.cjs", "astro.config.mjs" }
M.on_attach = function(_, _) end

local cmd = "astro-ls"

local function get_project_tslib()
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

local function validate()
  if vim.fn.executable(cmd) == 0 then
    utils.err.writeln(string.format("%s: Command not found. Check :help web-astro-lsp for more info.", cmd))
    return false
  end

  local is_global = vim.fn.executable("tsc") == 1
  if not is_global and get_project_tslib() == nil then
    utils.err.writeln(
      "Typescript not installed in project, run `npm install -D typescript`. Check :help web-astro-tsc for more info."
    )
    return false
  end

  return true
end

local function config(opts)
  return {
    name = "astro-lsp",
    cmd = { cmd, "--stdio" },
    on_attach = M.on_attach,
    init_options = {
      typescript = { tsdk = get_project_tslib() },
    },
    root_dir = utils.fs.find_nearest(M.root_dirs),
  }
end

function M.register_commands(bufnr) end

function M.setup(opts)
  vim.api.nvim_create_autocmd("FileType", {
    desc = "web: start astro lsp server and client",
    group = event.group("astro"),
    pattern = M.filetypes,
    callback = function(ev)
      if not validate() then
        return
      end

      M.on_attach = opts.on_attach
      vim.lsp.start(config(opts.lsp.astro))
      M.register_commands(ev.buf)
    end,
  })
end

return M
