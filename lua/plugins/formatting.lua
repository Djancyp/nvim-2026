-- Format on save off by default (same as old config). Toggle: <leader>uf (global) / <leader>uF (buffer)
if vim.g.autoformat == nil then
	vim.g.autoformat = false
end

local function autoformat_enabled(buf)
	if vim.b[buf].autoformat ~= nil then
		return vim.b[buf].autoformat
	end
	return vim.g.autoformat
end

return {
	-- Formatters (falls back to LSP formatting when none configured)
	{
		"stevearc/conform.nvim",
		dependencies = { "mason-org/mason.nvim" }, -- formatter binaries (see lsp.lua mason ensure_installed)
		event = "BufWritePre",
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format()
				end,
				mode = { "n", "x" },
				desc = "Format",
			},
			{
				"<leader>cF",
				function()
					require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
				end,
				mode = { "n", "x" },
				desc = "Format injected langs",
			},
			{
				"<leader>uf",
				function()
					vim.g.autoformat = not vim.g.autoformat
					vim.notify("Autoformat (global) " .. (vim.g.autoformat and "on" or "off"))
				end,
				desc = "Toggle autoformat (global)",
			},
			{
				"<leader>uF",
				function()
					vim.b.autoformat = not autoformat_enabled(0)
					vim.notify("Autoformat (buffer) " .. (vim.b.autoformat and "on" or "off"))
				end,
				desc = "Toggle autoformat (buffer)",
			},
		},
		opts = {
			default_format_opts = {
				timeout_ms = 3000,
				async = false,
				quiet = false,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				lua = { "stylua" },
				fish = { "fish_indent" },
				sh = { "shfmt" },
			},
			formatters = {
				injected = { options = { ignore_errors = true } },
			},
			format_on_save = function(buf)
				if autoformat_enabled(buf) then
					return {}
				end
			end,
		},
	},

	-- Linters, results shown as diagnostics
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			events = { "BufWritePost", "BufReadPost", "InsertLeave" },
			linters_by_ft = {
				fish = { "fish" },
				-- ["*"] = { "typos" }, -- all filetypes
				-- ["_"] = { "fallback linter" }, -- filetypes without other linters
			},
			-- override linter options or add custom linters; `condition = function(ctx)` supported
			linters = {},
		},
		config = function(_, opts)
			local lint = require("lint")
			for name, linter in pairs(opts.linters) do
				if type(linter) == "table" and type(lint.linters[name]) == "table" then
					lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
					if type(linter.prepend_args) == "table" then
						lint.linters[name].args = lint.linters[name].args or {}
						for i, arg in ipairs(linter.prepend_args) do
							table.insert(lint.linters[name].args, i, arg)
						end
					end
				else
					lint.linters[name] = linter
				end
			end
			lint.linters_by_ft = opts.linters_by_ft

			local function try_lint()
				local names = vim.list_extend({}, lint._resolve_linter_by_ft(vim.bo.filetype))
				if #names == 0 then
					vim.list_extend(names, lint.linters_by_ft["_"] or {})
				end
				vim.list_extend(names, lint.linters_by_ft["*"] or {})

				local ctx = { filename = vim.api.nvim_buf_get_name(0) }
				ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
				names = vim.tbl_filter(function(name)
					local linter = lint.linters[name]
					if not linter then
						vim.notify("Linter not found: " .. name, vim.log.levels.WARN, { title = "nvim-lint" })
					end
					return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
				end, names)

				if #names > 0 then
					lint.try_lint(names)
				end
			end

			local timer = assert(vim.uv.new_timer())
			vim.api.nvim_create_autocmd(opts.events, {
				group = vim.api.nvim_create_augroup("user-lint", { clear = true }),
				callback = function()
					timer:start(100, 0, vim.schedule_wrap(try_lint))
				end,
			})
		end,
	},
}
