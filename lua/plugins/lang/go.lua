-- https://www.lazyvim.org/extras/lang/go
return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "go", "gomod", "gowork", "gosum" } },
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			servers = {
				gopls = {
					init_options = {
						semanticTokens = true,
					},
					settings = {
						gopls = {
							gofumpt = true,
							codelenses = {
								gc_details = false,
								generate = true,
								regenerate_cgo = true,
								run_govulncheck = true,
								test = true,
								tidy = true,
								upgrade_dependency = true,
								vendor = true,
							},
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
							analyses = {
								nilness = true,
								unusedparams = true,
								unusedwrite = true,
								useany = true,
							},
							usePlaceholders = true,
							completeUnimported = true,
							staticcheck = true,
							directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
						},
					},
					-- workaround for gopls not advertising semanticTokensProvider
					-- https://github.com/golang/go/issues/54531#issuecomment-1464982242
					on_attach = function(client)
						if
							client.config.init_options
							and client.config.init_options.semanticTokens
							and not client.server_capabilities.semanticTokensProvider
						then
							local semantic = client.config.capabilities.textDocument.semanticTokens
							client.server_capabilities.semanticTokensProvider = {
								full = true,
								legend = {
									tokenTypes = semantic.tokenTypes,
									tokenModifiers = semantic.tokenModifiers,
								},
								range = true,
							}
						end
					end,
				},
			},
		},
	},
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "goimports", "gofumpt", "golangci-lint" } },
	},
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				go = { "golangcilint" },
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				go = { "goimports", "gofumpt" },
			},
		},
	},
	-- debugging: delve + nvim-dap-go set up in lua/plugins/dap.lua
	{
		"nvim-neotest/neotest",
		dependencies = { "fredrikaverpil/neotest-golang" },
		opts = {
			adapters = {
				["neotest-golang"] = {
					dap_go_enabled = true, -- requires leoluz/nvim-dap-go
				},
			},
		},
	},
	{
		"nvim-mini/mini.icons",
		opts = {
			file = {
				[".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
			},
			filetype = {
				gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
			},
		},
	},
}
