local icons = {
	diagnostics = { Error = " ", Warn = " ", Hint = " ", Info = " " },
	git = { added = " ", modified = " ", removed = " " },
}

-- noice hover/signature scroll, else your normal <C-f>/<C-b> (+ zz in normal mode)
local function scroll(delta, key)
	return function()
		if not require("noice.lsp").scroll(delta) then
			return vim.fn.mode() == "n" and key .. "zz" or key
		end
	end
end

return {
	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		init = function()
			vim.g.lualine_laststatus = vim.o.laststatus
			if vim.fn.argc(-1) > 0 then
				-- set an empty statusline till lualine loads
				vim.o.statusline = " "
			else
				-- hide the statusline on the dashboard
				vim.o.laststatus = 0
			end
		end,
		opts = function()
			vim.o.laststatus = vim.g.lualine_laststatus

			local opts = {
				options = {
					theme = "auto",
					globalstatus = vim.o.laststatus == 3,
					disabled_filetypes = { statusline = { "snacks_dashboard" } },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = {
						{
							-- project root, when it differs from cwd
							function()
								return "󱉭 " .. vim.fs.basename(vim.fs.root(0, ".git"))
							end,
							cond = function()
								local root = vim.fs.root(0, ".git")
								return root ~= nil and root ~= vim.uv.cwd()
							end,
						},
						{
							"diagnostics",
							symbols = {
								error = icons.diagnostics.Error,
								warn = icons.diagnostics.Warn,
								info = icons.diagnostics.Info,
								hint = icons.diagnostics.Hint,
							},
						},
						{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
						{ "filename", path = 1, symbols = { modified = "  ", readonly = " 󰌾 " } },
					},
					lualine_x = {
						-- Supermaven running (lua/plugins/ai.lua)
						{
							function()
								return " "
							end,
							cond = function()
								return package.loaded["supermaven-nvim"] ~= nil and require("supermaven-nvim.api").is_running()
							end,
							color = "Special",
						},
						-- stylua: ignore
						{
							function() return require("noice").api.status.command.get() end,
							cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
							color = "Statement",
						},
						-- stylua: ignore
						{
							function() return require("noice").api.status.mode.get() end,
							cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
							color = "Constant",
						},
						-- stylua: ignore
						{
							function() return "  " .. require("dap").status() end,
							cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
							color = "Debug",
						},
						-- stylua: ignore
						{
							require("lazy.status").updates,
							cond = require("lazy.status").has_updates,
							color = "Special",
						},
						{
							"diff",
							symbols = {
								added = icons.git.added,
								modified = icons.git.modified,
								removed = icons.git.removed,
							},
							source = function()
								local gitsigns = vim.b.gitsigns_status_dict
								if gitsigns then
									return {
										added = gitsigns.added,
										modified = gitsigns.changed,
										removed = gitsigns.removed,
									}
								end
							end,
						},
					},
					lualine_y = {
						{ "progress", separator = " ", padding = { left = 1, right = 0 } },
						{ "location", padding = { left = 0, right = 1 } },
					},
					lualine_z = {
						function()
							return " " .. os.date("%R")
						end,
					},
				},
				extensions = { "neo-tree", "lazy", "trouble" },
			}

			-- current symbol breadcrumb (Trouble)
			local symbols = require("trouble").statusline({
				mode = "symbols",
				groups = {},
				title = false,
				filter = { range = true },
				format = "{kind_icon}{symbol.name:Normal}",
				hl_group = "lualine_c_normal",
			})
			table.insert(opts.sections.lualine_c, {
				symbols.get,
				cond = function()
					return vim.b.trouble_lualine ~= false and symbols.has()
				end,
			})

			return opts
		end,
	},

	-- UI for messages, cmdline and popupmenu
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts_extend = { "routes" }, -- other files can add routes
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
		},
		-- stylua: ignore
		keys = {
			{ "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
			{ "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
			{ "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
			{ "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
			{ "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
			{ "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope)" },
			{ "<c-f>", scroll(4, "<c-f>"), silent = true, expr = true, desc = "Scroll Forward", mode = { "i", "n", "s" } },
			{ "<c-b>", scroll(-4, "<c-b>"), silent = true, expr = true, desc = "Scroll Backward", mode = { "i", "n", "s" } },
		},
		config = function(_, opts)
			-- don't replay messages from lazy install on startup
			if vim.o.filetype == "lazy" then
				vim.cmd([[messages clear]])
			end
			require("noice").setup(opts)
		end,
	},

	-- Icons (also stands in for nvim-web-devicons)
	{
		"nvim-mini/mini.icons",
		lazy = true,
		opts = {
			file = {
				[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
			},
		},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
}
