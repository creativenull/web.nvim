local prettier = require("web.tools.prettier")
local M = {}

function M.handle()
	vim.lsp.buf.format({
		async = false,
		timeout_ms = 5000,
		filter = function(client)
			return client.name == "tsserver" or client.name == "eslint-lsp"
		end,
	})

	if prettier.can_format() then
		prettier.format()
	end
end

return M
