local prettier = require("web.tools.prettier")
local M = {}

function M.handle()
	if prettier.get_executable() ~= "" then
		prettier.format()
	end
end

return M
