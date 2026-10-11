-- https://www.lazyvim.org/extras/lang/markdown
vim.filetype.add({
	extension = { mdx = "markdown.mdx" },
})

return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters = {
				-- only when file has a <!-- toc --> marker
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
					end,
				},
				-- only when markdownlint reports something
				["markdownlint-cli2"] = {
					condition = function(_, ctx)
						local diag = vim.tbl_filter(function(d)
							return d.source == "markdownlint"
						end, vim.diagnostic.get(ctx.buf))
						return #diag > 0
					end,
				},
			},
			formatters_by_ft = {
				["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
				["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
			},
		},
	},
	{
		"mason-org/mason.nvim",
		-- prettier: LazyVim gets it from its prettier extra
		opts = { ensure_installed = { "markdownlint-cli2", "markdown-toc", "prettier" } },
	},
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				markdown = { "markdownlint-cli2" },
			},
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			servers = {
				marksman = {},
			},
		},
	},

	-- Browser preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = function()
			require("lazy").load({ plugins = { "markdown-preview.nvim" } })
			vim.fn["mkdp#util#install"]()
		end,
		keys = {
			{
				"<leader>cp",
				ft = "markdown",
				"<cmd>MarkdownPreviewToggle<cr>",
				desc = "Markdown Preview",
			},
		},
		config = function()
			vim.cmd([[do FileType]])
		end,
	},

	-- Render headings, code blocks, tables in the buffer
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
		keys = {
			{
				"<leader>um",
				function()
					local rm = require("render-markdown")
					rm.set(not rm.get())
				end,
				desc = "Toggle Render Markdown",
			},
		},
		opts = {
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
			},
			heading = {
				sign = false,
				icons = {},
			},
			checkbox = {
				enabled = false,
			},
		},
	},
}
