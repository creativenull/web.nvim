local lsp_shared = require("web.lsp._shared")
local event = require("web.event")
local utils = require("web.utils")
local M = {}

local _name = "vtsls"
local _cmd = { "vtsls", "--stdio" }

M.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
M.root_dirs = { "tsconfig.json", "jsconfig.json", "package.json" }

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.report_error(string.format("%s: Command not found. Check :help web-vtsls for more info.", _cmd[1]))
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

  return function(err, result, ctx, config)
    if err or result == nil or vim.tbl_isempty(result) then
      return
    end

    local res = result_match(result)
    if res == nil then
      default_definition_fn(err, result, ctx, config)
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
    default_definition_fn(err, result, ctx, config)
  end
end

local function _config(tsserver_options, user_options, lsp_config)
  local inlay_hints = tsserver_options.inlay_hints
  local settings = {
    javascript = {
      inlayHints = {
        parameterNames = {
          enabled = (inlay_hints == "minimal" or inlay_hints == "all") and "all" or "none",
          suppressWhenArgumentMatchesName = inlay_hints == "minimal",
        },
        parameterTypes = { enabled = inlay_hints == "all" },
        variableTypes = {
          enabled = inlay_hints == "all",
          suppressWhenTypeMatchesName = inlay_hints == "minimal",
        },
        propertyDeclarationTypes = { enabled = inlay_hints == "all" },
        functionLikeReturnTypes = { enabled = inlay_hints == "minimal" or inlay_hints == "all" },
      },
    },
    typescript = {
      inlayHints = {
        parameterNames = {
          enabled = (inlay_hints == "minimal" or inlay_hints == "all") and "all" or "none",
          suppressWhenArgumentMatchesName = inlay_hints == "minimal",
        },
        parameterTypes = { enabled = inlay_hints == "all" },
        variableTypes = {
          enabled = inlay_hints == "all",
          suppressWhenTypeMatchesName = inlay_hints == "minimal",
        },
        propertyDeclarationTypes = { enabled = inlay_hints == "all" },
        functionLikeReturnTypes = { enabled = inlay_hints == "minimal" or inlay_hints == "all" },
        enumMemberValues = { enabled = inlay_hints == "all" },
      },
    },
  }

  if lsp_config and lsp_config.settings then
    settings = vim.tbl_extend("force", settings, lsp_config.settings)
  end

  local default_definition_fn = vim.lsp.handlers["textDocument/definition"]

  return {
    name = _name,
    cmd = _cmd,
    on_attach = user_options.on_attach,
    root_dir = utils.fs.find_nearest(M.root_dirs),
    handlers = { ["textDocument/definition"] = create_definition(default_definition_fn) },
    settings = settings,
  }
end

function M.set_user_commands(bufnr) end

function M.setup(user_options, lsp_config)
  if lsp_config and lsp_config.filetypes then
    vim.list_extend(M.filetypes, lsp_config.filetypes)
  end

  vim.api.nvim_create_autocmd("FileType", {
    desc = string.format("web.nvim: start %s", _name),
    group = event.group(_name),
    pattern = M.filetypes,
    callback = function(ev)
      if not _validate() then
        return
      end

      vim.lsp.start(_config(user_options.lsp.vtsls, user_options, lsp_config))
      M.set_user_commands(ev.buf)
    end,
  })
end

return M
