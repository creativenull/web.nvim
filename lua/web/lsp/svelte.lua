local event = require("web.event")
local utils = require("web.utils")
local M = {}

local _name = "svelte_ls"
local _cmd = { "svelteserver", "--stdio" }

M.filetypes = { "svelte" }
M.root_dirs = { "svelte.config.js", "svelte.config.ts", "svelte.config.cjs", "svelte.config.mjs" }

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.err.writeln(string.format("%s: Command not found. Check :help web-svelte-lsp for more info.", _cmd[1]))
    return false
  end

  return true
end

local function _config(svelte_options, user_options)
  local inlay_hints = svelte_options.inlay_hints

  return {
    name = _name,
    cmd = _cmd,
    on_attach = user_options.on_attach,
    root_dir = utils.fs.find_nearest(M.root_dirs),
    settings = {
      typescript = {
        inlayHints = {
          parameterNames = {
            enabled = (inlay_hints == "minimal" or inlay_hints == "all") and "all" or "none",
          },
          parameterTypes = {
            enabled = inlay_hints == "minimal" or inlay_hints == "all",
          },
          variableTypes = {
            enabled = inlay_hints == "all",
          },
          propertyDeclarationTypes = {
            enabled = inlay_hints == "minimal" or inlay_hints == "all",
          },
          functionLikeReturnTypes = {
            enabled = inlay_hints == "all",
          },
          enumMemberValues = {
            enabled = inlay_hints == "minimal" or inlay_hints == "all",
          },
        },
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

      vim.lsp.start(_config(user_options.lsp.svelte, user_options))
      M.set_user_commands(ev.buf)
    end,
  })
end

return M
