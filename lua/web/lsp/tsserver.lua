local event = require("web.event")
local utils = require("web.utils")
local M = {}

M.filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
M.root_dirs = { "tsconfig.json", "jsconfig.json" }
M.on_attach = function(_, _) end

local cmd = "typescript-language-server"

local function get_project_tsserverjs()
  local project_path = utils.fs.find_nearest({ "node_modules" })
  if project_path == nil then
    return nil
  end

  local path = string.format("%s/node_modules/typescript/lib/tsserver.js", project_path)
  if vim.fn.filereadable(path) == 0 then
    return nil
  end

  return path
end

local function validate()
  if vim.fn.executable(cmd) == 0 then
    utils.err.writeln(string.format("%s: Command not found. Check :help web-tsserver-lsp for more info.", cmd))
    return false
  end

  local is_global = vim.fn.executable("tsc") == 1
  if not is_global and get_project_tsserverjs() == nil then
    utils.err.writeln(
      "Typescript not installed in project, run `npm install -D typescript`. Check :help web-tsserver-tsc for more info."
    )
    return false
  end

  return true
end

local function config(tsserver_opts, init_options)
  local inlay_hints = false
  if tsserver_opts.inlay_hints then
    inlay_hints = true
  end

  init_options = vim.tbl_extend("force", {
    hostInfo = utils.host_info(),
    tsserver = { path = get_project_tsserverjs() },
  }, init_options ~= nil and init_options or {})

  return {
    name = "tsserver",
    cmd = { cmd, "--stdio" },
    on_attach = M.on_attach,
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

function M.register_commands(bufnr)
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

function M.setup(opts, filetypes, init_options)
  if filetypes ~= nil then
    vim.list_extend(filetypes, M.filetypes)
  else
    filetypes = M.filetypes
  end

  vim.api.nvim_create_autocmd("FileType", {
    desc = "web: start tsserver lsp server and client",
    group = event.group("tsserver"),
    pattern = filetypes,
    callback = function(ev)
      if not validate() then
        return
      end

      M.on_attach = opts.on_attach
      vim.lsp.start(config(opts.lsp.tsserver, init_options))
      M.register_commands(ev.buf)
    end,
  })
end

return M
