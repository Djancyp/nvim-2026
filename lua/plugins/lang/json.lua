-- https://www.lazyvim.org/extras/lang/json
return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "json5" } },
	},
	-- json/yaml schemas
	{
		"b0o/SchemaStore.nvim",
		lazy = true,
		version = false, -- last release is way too old
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			servers = {
				jsonls = {
					-- lazy-load schemastore when needed
					before_init = function(_, new_config)
						new_config.settings.json.schemas = new_config.settings.json.schemas or {}
						vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
					end,
					settings = {
						json = {
							format = { enable = true },
							validate = { enable = true },
						},
					},
				},
			},
		},
	},
}
