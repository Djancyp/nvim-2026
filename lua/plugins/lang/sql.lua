-- https://www.lazyvim.org/extras/lang/sql
-- Connections: set vim.g.dbs, e.g. in a project `.lazy.lua` (add it to .gitignore!):
--   vim.g.dbs = { dev = "postgres://user:pass@localhost:5432/db" }
--   return {}

local sql_ft = { "sql", "mysql", "plsql" }

-- disable nvim default `sql_completion` plugin to be compatible with blink.cmp's omni
-- while still showing some keywords from the syntax autocomplete sources
vim.g.omni_sql_default_compl_type = "syntax"
vim.g.loaded_sql_completion = true

return {
	{
		"tpope/vim-dadbod",
		cmd = "DB",
	},
	{
		"kristijanhusak/vim-dadbod-completion",
		dependencies = "tpope/vim-dadbod",
		ft = sql_ft,
	},
	{
		"kristijanhusak/vim-dadbod-ui",
		cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
		dependencies = "tpope/vim-dadbod",
		keys = {
			{ "<leader>D", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
		},
		init = function()
			local data_path = vim.fn.stdpath("data")

			vim.g.db_ui_auto_execute_table_helpers = 1
			vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
			vim.g.db_ui_show_database_icon = true
			vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
			vim.g.db_ui_use_nerd_fonts = true
			vim.g.db_ui_use_nvim_notify = true

			-- don't run queries on save (big queries can hang nvim); run with <leader>S
			vim.g.db_ui_execute_on_save = false
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "sql" } },
	},
	-- completion from the connected database
	{
		"saghen/blink.cmp",
		dependencies = { "kristijanhusak/vim-dadbod-completion" },
		opts = {
			sources = {
				default = { "dadbod" },
				providers = {
					dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
				},
			},
		},
	},
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "sqlfluff" } },
	},
	{
		"mfussenegger/nvim-lint",
		opts = function(_, opts)
			for _, ft in ipairs(sql_ft) do
				opts.linters_by_ft[ft] = opts.linters_by_ft[ft] or {}
				table.insert(opts.linters_by_ft[ft], "sqlfluff")
			end
		end,
	},
	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters.sqlfluff = {
				args = { "format", "--dialect=ansi", "-" },
			}
			for _, ft in ipairs(sql_ft) do
				opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
				table.insert(opts.formatters_by_ft[ft], "sqlfluff")
			end
		end,
	},
}
