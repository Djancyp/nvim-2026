-- https://www.lazyvim.org/extras/lang/rust
-- rust-analyzer is started by rustaceanvim (not lspconfig). Uses ~/.cargo/bin/rust-analyzer
return {
	-- LSP for Cargo.toml (versions, features, completion)
	{
		"Saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		opts = {
			completion = {
				crates = { enabled = true },
			},
			lsp = {
				enabled = true,
				actions = true,
				completion = true,
				hover = true,
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "rust", "ron" } },
	},
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "codelldb" } },
	},
	{
		"mrcjkb/rustaceanvim",
		ft = { "rust" },
		opts = {
			server = {
				on_attach = function(_, bufnr)
					vim.keymap.set("n", "<leader>cR", function()
						vim.cmd.RustLsp("codeAction")
					end, { desc = "Code Action", buffer = bufnr })
					vim.keymap.set("n", "<leader>dr", function()
						vim.cmd.RustLsp("debuggables")
					end, { desc = "Rust Debuggables", buffer = bufnr })
				end,
				default_settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							buildScripts = { enable = true },
						},
						-- clippy lints
						checkOnSave = true,
						diagnostics = { enable = true },
						procMacro = { enable = true },
						files = {
							exclude = {
								".direnv",
								".git",
								".jj",
								".github",
								".gitlab",
								"bin",
								"node_modules",
								"target",
								"venv",
								".venv",
							},
							-- avoid "Roots Scanned" hanging, see https://github.com/rust-lang/rust-analyzer/issues/12613#issuecomment-2096386344
							watcher = "client",
						},
					},
				},
			},
		},
		config = function(_, opts)
			-- debug adapter: mason's codelldb
			local codelldb = vim.fn.exepath("codelldb")
			if codelldb ~= "" then
				local library_path = vim.fn.expand("$MASON/opt/lldb/lib/liblldb.so")
				opts.dap = {
					adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
				}
			end
			vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
			if vim.fn.executable("rust-analyzer") == 0 then
				vim.notify(
					"rust-analyzer not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
					vim.log.levels.ERROR,
					{ title = "rustaceanvim" }
				)
			end
		end,
	},
	-- rustaceanvim owns rust-analyzer
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			servers = {
				rust_analyzer = { enabled = false },
			},
		},
	},
	{
		"nvim-neotest/neotest",
		opts = {
			adapters = {
				["rustaceanvim.neotest"] = {},
			},
		},
	},
}
