-- Write/read files as root (prompts for the sudo password)
--   :SudaWrite / :SudaRead, <leader>fS (also <leader>ss in lua/keys)
return {
	"lambdalisue/vim-suda",
	cmd = { "SudaWrite", "SudaRead" },
	keys = {
		{ "<leader>fS", "<cmd>SudaWrite<cr>", desc = "Sudo Write" },
	},
}
