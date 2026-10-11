return {
	-- Lua LSP knows about vim.* and plugin APIs
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "lazy.nvim", words = { "LazySpec" } },
				{ path = "nvim-lspconfig", words = { "lspconfig.settings" } },
			},
		},
	},

	-- Completion
	{
		"saghen/blink.cmp",
		version = "1.*", -- prebuilt fuzzy binary
		dependencies = { "rafamadriz/friendly-snippets" },
		event = "InsertEnter",
		opts_extend = { "sources.default" }, -- lang files can add sources
		opts = {
			keymap = { preset = "default" }, -- <C-y> accept, <C-n>/<C-p> select, <C-space> open
			completion = { documentation = { auto_show = true } },
			signature = { enabled = true },
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},
		},
	},

	-- Tool installer (formatters, linters, debuggers). Lang files extend `ensure_installed`
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = { "stylua", "shfmt" },
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local registry = require("mason-registry")
			registry.refresh(function()
				for _, tool in ipairs(opts.ensure_installed) do
					local ok, pkg = pcall(registry.get_package, tool)
					if ok and not pkg:is_installed() and not pkg:is_installing() then
						pkg:install()
					end
				end
			end)
		end,
	},

	-- LSP servers. Lang files (lua/plugins/lang/*) add to `servers`.
	-- Per server: any vim.lsp.Config field, plus
	--   mason = false  -> not installed by mason, enabled directly
	--   enabled = false -> never enabled
	--   keys = { { lhs, rhs, desc = "", mode = "n" } } -> buffer keymaps when that server attaches
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
		opts = {
			servers = {
				["*"] = {
					capabilities = {
						workspace = { fileOperations = { didRename = true, willRename = true } },
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							workspace = { checkThirdParty = false },
							codeLens = { enable = true },
							completion = { callSnippet = "Replace" },
							doc = { privateName = { "^_" } },
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
						},
					},
				},
				clangd = { mason = false }, -- system install
				stylua = { enabled = false }, -- formatter, not used as LSP
			},
		},
		config = function(_, opts)
			vim.diagnostic.config({
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
				float = { border = "rounded", source = true },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = " ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			})

			local servers = opts.servers or {}
			if servers["*"] then
				vim.lsp.config("*", servers["*"])
			end

			local mason_servers = vim.tbl_keys(require("mason-lspconfig").get_mappings().lspconfig_to_package)
			local install, exclude = {}, {}
			for name, server in pairs(servers) do
				if name ~= "*" then
					server = server == true and {} or server
					if server.enabled == false then
						exclude[#exclude + 1] = name
					else
						local config = vim.deepcopy(server)
						config.mason, config.enabled, config.keys = nil, nil, nil
						vim.lsp.config(name, config)
						if server.mason ~= false and vim.tbl_contains(mason_servers, name) then
							install[#install + 1] = name -- enabled by mason-lspconfig
						else
							vim.lsp.enable(name)
						end
					end
				end
			end

			require("mason-lspconfig").setup({
				ensure_installed = install,
				automatic_enable = { exclude = exclude },
			})

			local inlay_hint_exclude = { "vue" }

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if not client then
						return
					end
					local buf = ev.buf
					local map = function(mode, keys, fn, desc, extra)
						vim.keymap.set(mode, keys, fn, vim.tbl_extend("force", { buffer = buf, desc = "LSP: " .. desc }, extra or {}))
					end

					map("n", "gd", vim.lsp.buf.definition, "Goto definition")
					map("n", "gr", vim.lsp.buf.references, "References", { nowait = true })
					map("n", "gI", vim.lsp.buf.implementation, "Goto implementation")
					map("n", "gy", vim.lsp.buf.type_definition, "Goto type definition")
					map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
					map("n", "K", vim.lsp.buf.hover, "Hover")
					map("n", "gK", vim.lsp.buf.signature_help, "Signature help")
					map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
					map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
					map("n", "<leader>cA", function()
						vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
					end, "Source action")
					map("n", "<leader>co", function()
						vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" }, diagnostics = {} }, apply = true })
					end, "Organize imports")
					map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
					map("n", "<leader>ci", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
					end, "Toggle inlay hints")

					-- server specific keys
					for _, k in ipairs(vim.tbl_get(servers, client.name, "keys") or {}) do
						vim.keymap.set(k.mode or "n", k[1], k[2], { buffer = buf, desc = k.desc })
					end

					if
						client:supports_method("textDocument/inlayHint")
						and vim.bo[buf].buftype == ""
						and not vim.tbl_contains(inlay_hint_exclude, vim.bo[buf].filetype)
					then
						vim.lsp.inlay_hint.enable(true, { bufnr = buf })
					end

					if client:supports_method("textDocument/foldingRange") then
						local win = vim.api.nvim_get_current_win()
						vim.wo[win][0].foldmethod = "expr"
						vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
						vim.wo[win][0].foldlevel = 99
					end
				end,
			})
		end,
	},
}
