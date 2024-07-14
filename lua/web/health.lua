local M = {}

M.check = function()
  if _G._web == nil then
    _G._web = { health = { errors = {} } }
  end

  if not vim.tbl_isempty(_G._web.health.errors) then
    for _, msg in pairs(_G._web.health.errors) do
      vim.health.error(msg)
    end
  end
end

return M
