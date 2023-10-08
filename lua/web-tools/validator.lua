local M = {}

function M.validate_requirements()
	-- local mason_ok, _ = pcall(require, "mason")
	-- if not mason_ok then
	-- 	error("[web-tools] mason.nvim is required!")
	-- end
	--
	-- local lspconfig_ok, _ = pcall(require, "lspconfig")
	-- if not lspconfig_ok then
	-- 	error("[web-tools] lspconfig is required!")
	-- end
end

function M.validate_setup_opts(opts)
	vim.validate({
		-- ...
	})
end

return M
