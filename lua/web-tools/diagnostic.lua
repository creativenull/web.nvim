-- Adapted from:
-- https://github.com/neovim/neovim/blob/2e92065686f62851318150a315591c30b8306a4b/runtime/lua/vim/lsp/diagnostic.lua

local M = {}

---@return lsp.DiagnosticSeverity
local function severity_vim_to_lsp(severity)
	if type(severity) == "string" then
		severity = vim.diagnostic.severity[severity]
	end
	return severity
end

--- @param diagnostics Diagnostic[]
--- @return lsp.Diagnostic[]
function M.vim_to_lsp(diagnostics)
	---@diagnostic disable-next-line:no-unknown
	return vim.tbl_map(function(diagnostic)
		---@cast diagnostic Diagnostic
		return vim.tbl_extend("keep", {
			-- "keep" the below fields over any duplicate fields in diagnostic.user_data.lsp
			range = {
				start = {
					line = diagnostic.lnum,
					character = diagnostic.col,
				},
				["end"] = {
					line = diagnostic.end_lnum,
					character = diagnostic.end_col,
				},
			},
			severity = severity_vim_to_lsp(diagnostic.severity),
			message = diagnostic.message,
			source = diagnostic.source,
			code = diagnostic.code,
		}, diagnostic.user_data and (diagnostic.user_data.lsp or {}) or {})
	end, diagnostics)
end

return M
