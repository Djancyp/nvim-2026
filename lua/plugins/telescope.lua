local function builtin(name, opts)
	return function()
		require("telescope.builtin")[name](opts)
	end
end

return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-mini/mini.icons",
		},
		keys = {
			{ "<leader>sh", builtin("help_tags"), desc = "[S]earch [H]elp" },
			{ "<leader>sk", builtin("keymaps"), desc = "[S]earch [K]eymaps" },
			{ "<leader>sf", builtin("find_files"), desc = "[S]earch [F]iles" },
			{ "<leader>sss", builtin("builtin"), desc = "[S]earch [S]elect Telescope" },
			{ "<leader>sw", builtin("grep_string"), desc = "[S]earch current [W]ord" },
			{ "<leader>sg", builtin("live_grep"), desc = "[S]earch by [G]rep" },
			{ "<leader>sd", builtin("diagnostics"), desc = "[S]earch [D]iagnostics" },
			{ "<leader>sr", builtin("resume"), desc = "[S]earch [R]esume" },
			{ "<leader>s.", builtin("oldfiles"), desc = '[S]earch Recent Files ("." for repeat)' },
			{ "<leader><leader>", builtin("buffers"), desc = "[ ] Find existing buffers" },
			{ "<leader>fg", builtin("git_files"), desc = "[ ] git files" },
		},
		init = function()
			-- load telescope on first vim.ui.select (code actions etc.) so ui-select takes over
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("telescope")
				return vim.ui.select(...)
			end
		end,
		opts = function()
			return {
				defaults = {
					path_display = { "truncate" },
					mappings = {
						i = { ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" },
					},
				},
				pickers = {
					find_files = { hidden = true, file_ignore_patterns = { "^.git/" } },
				},
				extensions = {
					["ui-select"] = { require("telescope.themes").get_dropdown() },
				},
			}
		end,
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			pcall(telescope.load_extension, "fzf")
			pcall(telescope.load_extension, "ui-select")
		end,
	},
}
