-- Tell LSP servers about file moves/renames so imports get updated
local function lsp_rename(from, to)
	local changes = { files = { { oldUri = vim.uri_from_fname(from), newUri = vim.uri_from_fname(to) } } }
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client:supports_method("workspace/willRenameFiles") then
			local res = client:request_sync("workspace/willRenameFiles", changes, 1000, 0)
			if res and res.result then
				vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
			end
		end
		if client:supports_method("workspace/didRenameFiles") then
			client:notify("workspace/didRenameFiles", changes)
		end
	end
end

local function root()
	return vim.fs.root(0, ".git") or vim.uv.cwd()
end

return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-mini/mini.icons",
		},
		cmd = "Neotree",
		keys = {
			{
				"<leader>e",
				function()
					require("neo-tree.command").execute({ toggle = true, dir = root() })
				end,
				desc = "Explorer (root dir)",
			},
			{
				"<leader>E",
				function()
					require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
				end,
				desc = "Explorer (cwd)",
			},
			{
				"<leader>ge",
				function()
					require("neo-tree.command").execute({ source = "git_status", toggle = true })
				end,
				desc = "Git explorer",
			},
			{
				"<leader>be",
				function()
					require("neo-tree.command").execute({ source = "buffers", toggle = true })
				end,
				desc = "Buffer explorer",
			},
		},
		deactivate = function()
			vim.cmd("Neotree close")
		end,
		init = function()
			-- `nvim <dir>` opens neo-tree instead of netrw
			vim.api.nvim_create_autocmd("BufEnter", {
				group = vim.api.nvim_create_augroup("neotree-start-directory", { clear = true }),
				once = true,
				callback = function()
					if package.loaded["neo-tree"] then
						return
					end
					local stats = vim.uv.fs_stat(vim.fn.argv(0))
					if stats and stats.type == "directory" then
						require("neo-tree")
					end
				end,
			})
		end,
		opts = {
			sources = { "filesystem", "buffers", "git_status" },
			open_files_do_not_replace_types = { "terminal", "qf" },
			filesystem = {
				bind_to_cwd = false,
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
				hijack_netrw_behavior = "open_current",
			},
			window = {
				mappings = {
					["l"] = "open",
					["h"] = "close_node",
					["<space>"] = "none",
					["Y"] = {
						function(state)
							vim.fn.setreg("+", state.tree:get_node():get_id(), "c")
						end,
						desc = "Copy path to clipboard",
					},
					["O"] = {
						function(state)
							vim.ui.open(state.tree:get_node().path)
						end,
						desc = "Open with system app",
					},
					["P"] = { "toggle_preview", config = { use_float = false } },
				},
			},
			default_component_configs = {
				indent = {
					with_expanders = true,
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
				git_status = {
					symbols = {
						unstaged = "󰄱",
						staged = "󰱒",
					},
				},
			},
		},
		config = function(_, opts)
			local events = require("neo-tree.events")
			local on_move = function(data)
				lsp_rename(data.source, data.destination)
			end
			opts.event_handlers = opts.event_handlers or {}
			vim.list_extend(opts.event_handlers, {
				{ event = events.FILE_MOVED, handler = on_move },
				{ event = events.FILE_RENAMED, handler = on_move },
			})
			require("neo-tree").setup(opts)
		end,
	},
}
