local lsp_shared = require("web.lsp._shared")
local event = require("web.event")
local utils = require("web.utils")
local M = {}

local _name = "deno"
local _cmd = { "deno", "lsp" }

M.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc", "markdown" }
M.root_dirs = { "deno.json", "deno.jsonc" }

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.report_error(string.format("%s: Command not found. Check :help web-tsserver-lsp for more info.", _cmd[1]))

    return false
  end

  local is_global = vim.fn.executable("tsc") == 1
  if not is_global and lsp_shared.get_project_tslib() == "" then
    utils.err.writeln(
      "Typescript not installed in project, run `npm install -D typescript`. Check :help web-tsserver-tsc for more info."
    )

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

  local init_options = {
    hostInfo = utils.host_info(),
    tsserver = { path = lsp_shared.get_project_tslib() },
  }

  if lsp_config and lsp_config.init_options then
    init_options = vim.tbl_extend("force", init_options, lsp_config.init_options)
  end

  local default_definition_fn = vim.lsp.handlers["textDocument/definition"]

  return {
    name = _name,
    cmd = _cmd,
    on_attach = user_options.on_attach,
    root_dir = utils.fs.find_nearest(M.root_dirs),
    handlers = { ["textDocument/definition"] = create_definition(default_definition_fn) },
    init_options = init_options,
    settings = {
      javascript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = inlay_hints == "minimal" or inlay_hints == "all",
          includeInlayFunctionLikeReturnTypeHints = inlay_hints == "all",
          includeInlayFunctionParameterTypeHints = inlay_hints == "minimal" or inlay_hints == "all",
          includeInlayParameterNameHints = (inlay_hints == "minimal" or inlay_hints == "all") and "all" or "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = inlay_hints == "minimal" or inlay_hints == "all",
          includeInlayPropertyDeclarationTypeHints = inlay_hints == "minimal" or inlay_hints == "all",
          includeInlayVariableTypeHints = inlay_hints == "all",
          includeInlayVariableTypeHintsWhenTypeMatchesName = inlay_hints == "all",
        },
      },
      typescript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = inlay_hints == "minimal" or inlay_hints == "all",
          includeInlayFunctionLikeReturnTypeHints = inlay_hints == "all" or inlay_hints == "all",
          includeInlayFunctionParameterTypeHints = inlay_hints == "minimal" or inlay_hints == "all",
          includeInlayParameterNameHints = (inlay_hints == "minimal" or inlay_hints == "all") and "all" or "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = inlay_hints == "minimal" or inlay_hints == "all",
          includeInlayPropertyDeclarationTypeHints = inlay_hints == "minimal" or inlay_hints == "all",
          includeInlayVariableTypeHints = inlay_hints == "all",
          includeInlayVariableTypeHintsWhenTypeMatchesName = inlay_hints == "all",
        },
      },
    },
  }
end

function M.set_user_commands(bufnr)
  -- https://www.reddit.com/r/neovim/comments/lwz8l7/comment/gpkueno/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  vim.api.nvim_buf_create_user_command(bufnr, "WebTsserverOrganizeImports", function()
    vim.lsp.buf.execute_command({
      command = "_typescript.organizeImports",
      arguments = { vim.api.nvim_buf_get_name(0) },
      title = "",
    })
  end, {})

  vim.api.nvim_buf_create_user_command(bufnr, "WebTsserverGoToSourceDefinition", function()
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "tsserver" })
    if vim.tbl_isempty(clients) then
      return
    end

    local client = clients[1]
    local winid = vim.api.nvim_get_current_win()
    local handler = function(_, result)
      if result == nil or vim.tbl_isempty(result) then
        return
      end

      local response = result[1]
      local fname = vim.uri_to_fname(response.uri)
      local lnum = response.range.start.line
      local col = response.range.start.character

      vim.cmd(string.format("edit %s", fname))
      vim.api.nvim_win_set_cursor(winid, { lnum + 1, col })
    end

    vim.api.nvim_notify("web: Opening source file", vim.log.levels.WARN, {})

    local params = vim.lsp.util.make_position_params(winid)
    client.request("workspace/executeCommand", {
      command = "_typescript.goToSourceDefinition",
      arguments = { params.textDocument.uri, params.position },
    }, handler, bufnr)
  end, {})
end

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

      vim.lsp.start(_config(user_options.lsp.tsserver, user_options, lsp_config))
      M.set_user_commands(ev.buf)
    end,
  })
end

return M
