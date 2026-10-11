-- https://www.lazyvim.org/extras/lang/yaml
return {
	{
		"b0o/SchemaStore.nvim",
		lazy = true,
		version = false, -- last release is way too old
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			servers = {
				yamlls = {
					-- tell yamlls we support line folding
					capabilities = {
						textDocument = {
							foldingRange = {
								dynamicRegistration = false,
								lineFoldingOnly = true,
							},
						},
					},
					-- lazy-load schemastore when needed
					before_init = function(_, new_config)
						new_config.settings.yaml.schemas = vim.tbl_deep_extend(
							"force",
							new_config.settings.yaml.schemas or {},
							require("schemastore").yaml.schemas()
						)
					end,
					settings = {
						redhat = { telemetry = { enabled = false } },
						yaml = {
							keyOrdering = false,
							format = { enable = true },
							validate = true,
							schemaStore = {
								-- disable built-in schemaStore to use SchemaStore.nvim
								enable = false,
								-- avoid TypeError: Cannot read properties of undefined (reading 'length')
								url = "",
							},
						},
					},
				},
			},
		},
	},
}
