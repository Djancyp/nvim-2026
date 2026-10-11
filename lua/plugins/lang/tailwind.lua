-- https://www.lazyvim.org/extras/lang/tailwind
-- (LazyVim's tailwindcss-colorizer-cmp part is nvim-cmp only; blink.cmp is used here)
local filetypes_exclude = { "markdown" }
local filetypes_include = {}

return {
	{
		"mason-org/mason-lspconfig.nvim",
		opts = function(_, opts)
			-- nvim-lspconfig default filetypes, minus excluded, plus included
			local filetypes = vim.tbl_filter(function(ft)
				return not vim.tbl_contains(filetypes_exclude, ft)
			end, vim.deepcopy(vim.lsp.config.tailwindcss.filetypes or {}))
			vim.list_extend(filetypes, filetypes_include)

			opts.servers.tailwindcss = {
				filetypes = filetypes,
				settings = {
					tailwindCSS = {
						-- Phoenix projects
						includeLanguages = {
							elixir = "html-eex",
							eelixir = "html-eex",
							heex = "html-eex",
						},
					},
				},
			}
		end,
	},
}
