local utils = require("web.utils")
local M = {}

local function handle_cmd_complete()
  local packagejson_filepath = string.format("%s/package.json", vim.loop.cwd())
  if vim.fn.filereadable(packagejson_filepath) == 0 then
    return {}
  end

  local packageJsonContents = utils.fs.readfile(packagejson_filepath)
  if not packageJsonContents then
    return {}
  end

  local json = vim.json.decode(packageJsonContents)
  if vim.tbl_isempty(json.scripts) then
    return {}
  end

  return vim.tbl_keys(json.scripts)
end

local function handle_cmd(cmd)
  local script = cmd.fargs[1]
  local pm = utils.fs.get_package_manager()

  if pm == "npm" then
    vim.cmd(string.format("terminal npm run %s", script))
  elseif pm == "yarn" then
    vim.cmd(string.format("terminal yarn %s", script))
  elseif pm == "pnpm" then
    vim.cmd(string.format("terminal pnpm %s", script))
  end
end

function M.setup(opts)
  vim.api.nvim_create_user_command("WebRun", handle_cmd, {
    nargs = 1,
    complete = handle_cmd_complete,
  })
end

return M
