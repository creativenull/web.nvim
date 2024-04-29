local lsp_shared = require("web.lsp._shared")
local event = require("web.event")
local utils = require("web.utils")
local M = {}

local _name = "volar"
local _cmd = { "vue-language-server", "--stdio" }

M.filetypes = { "vue" }
M.root_dirs = { "vue.config.js", "vue.config.ts", "nuxt.config.js", "nuxt.config.ts" }

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.err.writeln(string.format("%s: Command not found. Check :help web-vue-lsp for more info.", _cmd[1]))
    return false
  end

  return true
end

local function create_definition(default_definition_fn)
  local matches = { "components.d.ts", "auto-imports.d.ts" }

  ---Check if the targetUri matches the files listed above
  local function result_match(results)
    for _, res in pairs(results) do
      for _, fname in pairs(matches) do
        if vim.endswith(res.targetUri, fname) then
          return res
        end
      end
    end

    return nil
  end

  ---Open the file only if it's a vue/js/ts file
  local function open_filename(targetUri_fname, matched_fname)
    local target_fname = string.format("%s/%s", vim.fs.dirname(targetUri_fname), matched_fname)

    if vim.endswith(target_fname, ".vue") then
      vim.cmd(string.format("edit %s", target_fname))
    else
      -- Assume js/ts filename instead
      local ext = ".js"
      if vim.fn.filereadable(target_fname .. ext) == 0 then
        ext = ".ts"
      end

      vim.cmd(string.format("edit %s%s", target_fname, ext))
    end
  end

  return function(err, results, ctx, config)
    if err or results == nil or vim.tbl_isempty(results) then
      return
    end

    local res = result_match(results)
    if res == nil then
      default_definition_fn(err, results, ctx, config)
      return
    end

    -- Take the start line as the index and get only that
    -- line as content_line for the match
    local fname = vim.uri_to_fname(res.targetUri)
    local sline = res.targetRange.start.line
    local contents = vim.fn.readfile(fname)
    local content_line = vim.trim(contents[sline + 1])
    local matched_filename = vim.fn.matchlist(content_line, "typeof import(['\"]\\(\\.*/.*\\)['\"])")

    if not vim.tbl_isempty(matched_filename) then
      open_filename(fname, matched_filename[2])
      return
    end

    -- Always default to builtin behavior, if anything fails
    default_definition_fn(err, results, ctx, config)
  end
end

local function _config(volar_options, user_options)
  local default_definition_fn = vim.lsp.handlers["textDocument/definition"]

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
    handlers = {
      ["textDocument/definition"] = create_definition(default_definition_fn),
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

      vim.lsp.start(_config(user_options.lsp.volar, user_options))
      M.set_user_commands(ev.buf)
    end,
  })
end

---Get the language server path for ts plugin integration/hybrid mode.
---Check within a mason registry, otherwise globally.
---@return string
function M.get_server_path()
  local is_mason, _ = pcall(require, "mason")

  if is_mason then
    return string.format(
      "%s/node_modules/@vue/language-server",
      require("mason-registry").get_package("vue-language-server"):get_install_path()
    )
  else
    local result = vim.fn.systemlist("npm root --global")
    if vim.v.shell_error ~= 0 then
      utils.warn("nodejs not installed in your machine")

      return ""
    end

    return string.format("%s/@vue/language-server", result[1])
  end
end

return M
