-- https://www.lazyvim.org/extras/ai/supermaven
-- Inline ghost-text suggestions. First run: :SupermavenUseFree or :SupermavenUsePro
--   <Tab>  accept suggestion (after snippet jump, else normal Tab)
--   <C-l>  accept next word
--   <C-]>  dismiss
-- statusline icon: lua/plugins/ui.lua

local function preview()
	return require("supermaven-nvim.completion_preview")
end

-- accept if there is a suggestion; returns true when handled
local function ai_accept()
	if package.loaded["supermaven-nvim"] and preview().has_suggestion() then
		vim.api.nvim_feedkeys(vim.keycode("<C-g>u"), "n", false) -- undo break before insert
		vim.schedule(function()
			preview().on_accept_suggestion()
		end)
		return true
	end
end

return {
	{
		"supermaven-inc/supermaven-nvim",
		event = "InsertEnter",
		cmd = { "SupermavenUseFree", "SupermavenUsePro" },
		opts = {
			disable_keymaps = true, -- mapped below / in blink
			ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif", "TelescopePrompt", "neo-tree-popup" },
		},
		config = function(_, opts)
			require("supermaven-nvim").setup(opts)
			vim.keymap.set("i", "<C-l>", function()
				if preview().has_suggestion() then
					preview().on_accept_suggestion_word()
				end
			end, { desc = "Accept AI word" })
			vim.keymap.set("i", "<C-]>", function()
				preview().on_dispose_inlay()
			end, { desc = "Dismiss AI suggestion" })
		end,
	},

	-- <Tab>: snippet jump -> AI accept -> normal Tab
	{
		"saghen/blink.cmp",
		opts = {
			keymap = {
				["<Tab>"] = { "snippet_forward", ai_accept, "fallback" },
			},
		},
	},

	-- hide startup chatter
	{
		"folke/noice.nvim",
		opts = {
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "Starting Supermaven" },
							{ find = "Supermaven Free Tier" },
						},
					},
					skip = true,
				},
			},
		},
	},
}
