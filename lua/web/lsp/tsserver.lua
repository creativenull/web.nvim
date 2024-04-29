local lsp_shared = require("web.lsp._shared")
local event = require("web.event")
local utils = require("web.utils")
local M = {}

local _name = "tsserver"
local _cmd = { "typescript-language-server", "--stdio" }

M.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
M.root_dirs = { "tsconfig.json", "jsconfig.json" }

local function _validate()
  if vim.fn.executable(_cmd[1]) == 0 then
    utils.err.writeln(string.format("%s: Command not found. Check :help web-tsserver-lsp for more info.", _cmd[1]))
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

local function _config(tsserver_options, user_options, lsp_config)
  local inlay_hints = false
  if tsserver_options.inlay_hints then
    inlay_hints = true
  end

  local init_options = {
    hostInfo = utils.host_info(),
    tsserver = { path = lsp_shared.get_project_tslib() },
  }

  if lsp_config.init_options then
    init_options = vim.tbl_extend("force", init_options, lsp_config.init_options)
  end

  return {
    name = _name,
    cmd = _cmd,
    on_attach = user_options.on_attach,
    root_dir = utils.fs.find_nearest(M.root_dirs),
    init_options = init_options,
    settings = {
      javascript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = inlay_hints,
          includeInlayFunctionLikeReturnTypeHints = inlay_hints,
          includeInlayFunctionParameterTypeHints = inlay_hints,
          includeInlayParameterNameHints = inlay_hints and "all" or "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = inlay_hints,
          includeInlayPropertyDeclarationTypeHints = inlay_hints,
          includeInlayVariableTypeHints = inlay_hints,
          includeInlayVariableTypeHintsWhenTypeMatchesName = inlay_hints,
        },
      },
      typescript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = inlay_hints,
          includeInlayFunctionLikeReturnTypeHints = inlay_hints,
          includeInlayFunctionParameterTypeHints = inlay_hints,
          includeInlayParameterNameHints = inlay_hints and "all" or "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = inlay_hints,
          includeInlayPropertyDeclarationTypeHints = inlay_hints,
          includeInlayVariableTypeHints = inlay_hints,
          includeInlayVariableTypeHintsWhenTypeMatchesName = inlay_hints,
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
