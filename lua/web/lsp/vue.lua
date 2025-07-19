local lsp_shared = require("web.lsp._shared")
local event = require("web.event")
local utils = require("web.utils")
local M = {}

local _name = "vue_ls"
local _cmd = { "vue-language-server", "--stdio" }

M.filetypes = { "vue" }
M.root_dirs = { "nuxt.config.js", "nuxt.config.ts", "vite.config.js", "vite.config.ts" }

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.report_error(string.format("%s: Command not found. Check :help web-vue-lsp for more info.", _cmd[1]))
    return false
  end

  return true
end

local function _config(vue_options, user_options)
  return {
    name = _name,
    cmd = _cmd,
    on_attach = user_options.on_attach,
    capabilities = user_options.capabilities,
    root_dir = utils.fs.find_nearest(M.root_dirs),
    init_options = {
      typescript = { tsdk = lsp_shared.get_project_tslib() },
      vue = { hybridMode = true },
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

      vim.lsp.start(_config(user_options.lsp.vue, user_options))
      M.set_user_commands(ev.buf)
    end,
  })
end

---Get the language server path for ts plugin integration/hybrid mode.
---Check within a mason registry, otherwise globally.
---@return string
function M.get_server_path()
  local function ensure_mason_package()
    return require("mason-registry").is_installed("vue-language-server")
  end

  local is_mason, installed = pcall(ensure_mason_package)

  if is_mason and installed then
    return string.format(
      "%s/node_modules/@vue/language-server",
      require("mason-registry").get_package("vue-language-server"):get_install_path()
    )
  else
    -- TODO: Find a way to cache this so we don't have to keep calling the command
    --       to check the global node_modules path.
    local result = vim.fn.systemlist("npm root --global")
    if vim.v.shell_error ~= 0 then
      utils.warn("nodejs must be installed to use the vue-language-server")

      return ""
    end

    return string.format("%s/@vue/language-server", result[1])
  end
end

return M
