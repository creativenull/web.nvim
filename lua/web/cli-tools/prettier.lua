local utils = require("web.utils")
local M = {}

local _allowed = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "css",
  "html",
  "json",
}

---Get the exectuable path of prettier. A classic fizz-buzz solution.
---@return string
function M.get_executable()
  local tool = string.format("%s/node_modules/.bin/prettier", vim.loop.cwd())
  local global_tool = vim.fn.exepath("prettier")

  if vim.fn.filereadable(tool) == 0 and vim.fn.filereadable(global_tool) == 0 then
    return ""
  elseif vim.fn.filereadable(tool) == 1 and vim.fn.filereadable(global_tool) == 0 then
    -- Use the project provided prettier
    return tool
  else
    -- Use the globally provided pretter
    return global_tool
  end
end

---Check if prettier can be used to format code.
---@return boolean
function M.can_format()
  local ft = vim.api.nvim_buf_get_option(vim.api.nvim_get_current_buf(), "filetype")
  return M.get_executable() ~= "" and vim.tbl_contains(_allowed, ft)
end

---Format the current buffer code using prettier, using vim jobs.
---@return nil
function M.format()
  local buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(buf)
  local bufcontents = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local tool = M.get_executable()

  if tool == "" then
    utils.report_error("Prettier not installed. Install with `npm i -D prettier`.")
    return
  end

  local command = { tool, "--stdin-filepath", filename }
  local jobid = vim.fn.jobstart(command, {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
    end,
  })
  vim.fn.chansend(jobid, table.concat(bufcontents, "\n"))
  vim.fn.chanclose(jobid, "stdin")
end

return M
