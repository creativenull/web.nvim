local event = require("web.event")
local utils = require("web.utils")
local M = {}

local _name = "language-server-name"
local _cmd = { "language-server-binary", "--stdio" }

M.filetypes = {}
M.root_dirs = {}
M.on_attach = function(_, _) end

local function _validate() end

local function _config(on_attach, capabilities, lspconfig)
	return {
		name = _name,
		cmd = _cmd,
		on_attach = on_attach,
		capabilities = capabilities,
		root_dir = utils.fs.find_nearest(M.root_dirs),
	}
end

function M.set_user_commands(bufnr) end

function M.setup(opts)
	vim.api.nvim_create_autocmd("FileType", {
		desc = string.format("web.nvim: start %s", _name),
		group = event.group(_name),
		pattern = M.filetypes,
		callback = function(ev)
			if not _validate() then
				return
			end

			-- vim.lsp.start(_config(opts.on_attach, opts.capabilities, opts.lsp.<name>))
		end,
	})
end

return M
