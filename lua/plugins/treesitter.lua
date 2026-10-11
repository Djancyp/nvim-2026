-- Is there a parser (and optionally a query) for this filetype?
local function have(ft, query)
	local lang = vim.treesitter.language.get_lang(ft)
	if not lang or not pcall(vim.treesitter.language.add, lang) then
		return false
	end
	return query == nil or vim.treesitter.query.get(lang, query) ~= nil
end

return {
	-- Parsers + highlight / indent / folds
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		version = false,
		build = ":TSUpdate",
		lazy = false, -- main branch does not support lazy-loading
		cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
		opts_extend = { "ensure_installed" }, -- lang files add parsers
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			folds = { enable = true },
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"diff",
				"go",
				"gomod",
				"gosum",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"printf",
				"python",
				"query",
				"regex",
				"rust",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			},
		},
		config = function(_, opts)
			local TS = require("nvim-treesitter")
			TS.setup(opts)

			local installed = TS.get_installed()
			local missing = vim.tbl_filter(function(lang)
				return not vim.tbl_contains(installed, lang)
			end, opts.ensure_installed)
			if #missing > 0 then
				TS.install(missing, { summary = true })
			end

			local function enabled(feat, ft, lang, query)
				local f = opts[feat] or {}
				return f.enable ~= false
					and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
					and have(ft, query)
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("user-treesitter", { clear = true }),
				callback = function(ev)
					local ft = ev.match
					local lang = vim.treesitter.language.get_lang(ft)
					if not have(ft) then
						return
					end
					if enabled("highlight", ft, lang, "highlights") then
						pcall(vim.treesitter.start, ev.buf)
					end
					if enabled("indent", ft, lang, "indents") then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
					if enabled("folds", ft, lang, "folds") then
						-- LSP folds (lsp.lua) override this when the server supports them
						vim.wo[0][0].foldmethod = "expr"
						vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
						vim.wo[0][0].foldlevel = 99
					end
				end,
			})
		end,
	},

	-- ]f [f ]c [c ]a [a: jump between functions / classes / params
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = "VeryLazy",
		opts = {
			move = {
				enable = true,
				set_jumps = true,
				keys = {
					goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
					goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
					goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
					goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter-textobjects").setup(opts)

			local function attach(buf)
				if not (vim.tbl_get(opts, "move", "enable") and have(vim.bo[buf].filetype, "textobjects")) then
					return
				end
				for method, keymaps in pairs(vim.tbl_get(opts, "move", "keys") or {}) do
					for key, query in pairs(keymaps) do
						local part = query:gsub("@", ""):gsub("%..*", "")
						local desc = (key:sub(1, 1) == "[" and "Prev " or "Next ")
							.. part:sub(1, 1):upper()
							.. part:sub(2)
							.. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
						vim.keymap.set({ "n", "x", "o" }, key, function()
							if vim.wo.diff and key:find("[cC]") then
								return vim.cmd("normal! " .. key)
							end
							require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
						end, { buffer = buf, desc = desc, silent = true })
					end
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("user-treesitter-textobjects", { clear = true }),
				callback = function(ev)
					attach(ev.buf)
				end,
			})
			vim.tbl_map(attach, vim.api.nvim_list_bufs())
		end,
	},

	-- Auto close/rename HTML & JSX tags
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
	},
}
