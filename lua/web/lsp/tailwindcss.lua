local event = require("web.event")
local utils = require("web.utils")
local M = {}

local _name = "tailwindcss_ls"
local _cmd = { "tailwindcss-language-server", "--stdio" }

M.filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue", "astro", "svelte" }
M.root_dirs = { "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.mjs", "tailwind.config.ts" }

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.report_error(string.format("%s: Command not found. Check :help web-tailwindcss-lsp for more info.", _cmd[1]))
    return false
  end

  return true
end

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
  if
    user_options.lsp.tailwindcss.additional_filetypes ~= nil
    and type(user_options.lsp.tailwindcss.additional_filetypes) == "table"
  then
    vim.list_extend(M.filetypes, user_options.lsp.tailwindcss.additional_filetypes)
  end

  vim.api.nvim_create_autocmd("FileType", {
    desc = string.format("web.nvim: start %s", _name),
    group = event.group(_name),
    pattern = M.filetypes,
    callback = function(ev)
      if not _validate() then
        return
      end

      vim.lsp.start(_config(user_options.lsp.tailwindcss, user_options))
      M.set_user_commands(ev.buf)
    end,
  })
end

return M
