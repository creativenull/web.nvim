local utils = require("web.utils")
local M = {}

function M.register_lsp_cmds(bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, "WebQuickfixAction", function(cmd)
    vim.lsp.buf.code_action({
      context = { only = { "quickfix" }, triggerKind = 1 },
      range = {
        ["start"] = { cmd.line1, 0 },
        ["end"] = { cmd.line2, 0 },
      },
    })
  end, { range = true })

  vim.api.nvim_buf_create_user_command(bufnr, "WebRefactorAction", function(cmd)
    vim.lsp.buf.code_action({
      context = { only = { "refactor" }, triggerKind = 1 },
      range = {
        ["start"] = { cmd.line1, 0 },
        ["end"] = { cmd.line2, 0 },
      },
    })
  end, { range = true })

  vim.api.nvim_buf_create_user_command(bufnr, "WebSourceAction", function(cmd)
    vim.lsp.buf.code_action({
      context = { only = { "source" }, triggerKind = 1 },
      range = {
        ["start"] = { cmd.line1, 0 },
        ["end"] = { cmd.line2, 0 },
      },
    })
  end, { range = true })

  vim.api.nvim_buf_create_user_command(bufnr, "WebLspFormat", require("web.format"), {})
end

---Get the typescript lib path inside node_modules.
---Return empty string, if not found.
---@return string
function M.get_project_tslib()
  local project_path = utils.fs.find_nearest({ "node_modules" })
  if project_path == nil then
    return ""
  end

  local path = string.format("%s/node_modules/typescript/lib", project_path)
  if vim.fn.isdirectory(path) == 0 then
    return ""
  end

  return path
end

return M
