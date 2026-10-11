-- https://www.lazyvim.org/extras/lang/docker

-- nvim detects compose files as plain `yaml`; compose LSP needs `yaml.docker-compose`
vim.filetype.add({
	filename = {
		["compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["docker-compose.yml"] = "yaml.docker-compose",
	},
})
vim.treesitter.language.register("yaml", "yaml.docker-compose")

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "dockerfile" } },
	},
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "hadolint" } },
	},
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				dockerfile = { "hadolint" },
			},
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			servers = {
				dockerls = {},
				docker_compose_language_service = {},
			},
		},
	},
}
