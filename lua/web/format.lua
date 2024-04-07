local prettier = require("web.tools.prettier")
local eslint = require("web.tools.eslint")
local M = {}

function M.handle()
	-- if eslint.get_executable() ~= "" then
	-- 	eslint.format()
	-- end

	if prettier.get_executable() ~= "" then
		prettier.format()
	end
end

return M
