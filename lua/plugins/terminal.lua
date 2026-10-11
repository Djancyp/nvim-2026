-- LazyVim terminal: floating Snacks.terminal
--   <C-/>        toggle terminal (project root), normal + terminal mode
--   <leader>ft   terminal (project root), <leader>fT terminal (cwd)
--   <Esc><Esc>   terminal -> normal mode (lua/keys)

local function root()
	return vim.fs.root(0, ".git") or vim.uv.cwd()
end

-- <C-hjkl>: move between windows from a split terminal, pass through in a floating one
local function term_nav(dir)
	---@param self snacks.terminal
	return function(self)
		return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
			vim.cmd.wincmd(dir)
		end)
	end
end

local function toggle()
	Snacks.terminal.focus(nil, { cwd = root() })
end

return {
	{
		"folke/snacks.nvim",
		opts = {
			terminal = {
				win = {
					keys = {
						nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
						nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
						nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
						nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
						hide_slash = { "<C-/>", "hide", desc = "Hide Terminal", mode = "t" },
						hide_underscore = { "<c-_>", "hide", desc = "Hide Terminal", mode = "t" },
					},
				},
			},
		},
		keys = {
			{
				"<leader>fT",
				function()
					Snacks.terminal()
				end,
				desc = "Terminal (cwd)",
			},
			{
				"<leader>ft",
				function()
					Snacks.terminal(nil, { cwd = root() })
				end,
				desc = "Terminal (Root Dir)",
			},
			{ "<C-/>", toggle, mode = { "n", "t" }, desc = "Terminal (Root Dir)" },
			-- many terminals send <C-_> for <C-/>
			{ "<C-_>", toggle, mode = { "n", "t" }, desc = "Terminal (Root Dir)" },
		},
	},
}
