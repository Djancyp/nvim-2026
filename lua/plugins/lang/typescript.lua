-- https://www.lazyvim.org/extras/lang/typescript (vtsls)
-- debugging (js-debug-adapter) set up in lua/plugins/dap.lua

-- Run a vtsls command; `open = true` shows the resulting locations in Trouble
local function execute(opts)
	local params = { command = opts.command, arguments = opts.arguments }
	if opts.open then
		require("trouble").open({ mode = "lsp_command", params = params })
	else
		local client = vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })[1]
		if client then
			client:exec_cmd({ title = opts.title or opts.command, command = opts.command, arguments = opts.arguments })
		end
	end
end

local function action(kind)
	return function()
		vim.lsp.buf.code_action({ apply = true, context = { only = { kind }, diagnostics = {} } })
	end
end

-- "Move to file" refactor: ask for destination
local function move_to_file_refactoring(client)
	client.commands["_typescript.moveToFileRefactoring"] = function(command)
		---@type string, string, lsp.Range
		local act, uri, range = unpack(command.arguments)

		local function move(newf)
			client:request("workspace/executeCommand", {
				command = command.command,
				arguments = { act, uri, range, newf },
			})
		end

		local fname = vim.uri_to_fname(uri)
		client:request("workspace/executeCommand", {
			command = "typescript.tsserverRequest",
			arguments = {
				"getMoveToRefactoringFileSuggestions",
				{
					file = fname,
					startLine = range.start.line + 1,
					startOffset = range.start.character + 1,
					endLine = range["end"].line + 1,
					endOffset = range["end"].character + 1,
				},
			},
		}, function(_, result)
			---@type string[]
			local files = result.body.files
			table.insert(files, 1, "Enter new path...")
			vim.ui.select(files, {
				prompt = "Select move destination:",
				format_item = function(f)
					return vim.fn.fnamemodify(f, ":~:.")
				end,
			}, function(f)
				if f and f:find("^Enter new path") then
					vim.ui.input({
						prompt = "Enter move destination:",
						default = vim.fn.fnamemodify(fname, ":h") .. "/",
						completion = "file",
					}, function(newf)
						return newf and move(newf)
					end)
				elseif f then
					move(f)
				end
			end)
		end)
	end
end

local ts_settings = {
	updateImportsOnFileMove = { enabled = "always" },
	suggest = {
		completeFunctionCalls = true,
	},
	inlayHints = {
		enumMemberValues = { enabled = true },
		functionLikeReturnTypes = { enabled = true },
		parameterNames = { enabled = "literals" },
		parameterTypes = { enabled = true },
		propertyDeclarationTypes = { enabled = true },
		variableTypes = { enabled = false },
	},
}

return {
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			servers = {
				-- only vtsls
				tsserver = { enabled = false },
				ts_ls = { enabled = false },
				vtsls = {
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx",
					},
					settings = {
						complete_function_calls = true,
						vtsls = {
							enableMoveToFileCodeAction = true,
							autoUseWorkspaceTsdk = true,
							experimental = {
								maxInlayHintLength = 30,
								completion = {
									enableServerSideFuzzyMatch = true,
								},
							},
						},
						typescript = ts_settings,
						javascript = vim.deepcopy(ts_settings),
					},
					on_attach = move_to_file_refactoring,
					keys = {
						{
							"gD",
							function()
								local win = vim.api.nvim_get_current_win()
								local params = vim.lsp.util.make_position_params(win, "utf-16")
								execute({
									command = "typescript.goToSourceDefinition",
									arguments = { params.textDocument.uri, params.position },
									open = true,
								})
							end,
							desc = "Goto Source Definition",
						},
						{
							"gR",
							function()
								execute({
									command = "typescript.findAllFileReferences",
									arguments = { vim.uri_from_bufnr(0) },
									open = true,
								})
							end,
							desc = "File References",
						},
						{ "<leader>cM", action("source.addMissingImports.ts"), desc = "Add missing imports" },
						{ "<leader>cD", action("source.fixAll.ts"), desc = "Fix all diagnostics" },
						{
							"<leader>cV",
							function()
								execute({ title = "Select TypeScript Version", command = "typescript.selectTypeScriptVersion" })
							end,
							desc = "Select TS workspace version",
						},
					},
				},
			},
		},
	},
	{
		"nvim-mini/mini.icons",
		opts = {
			file = {
				[".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
				[".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
				[".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
				[".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
				["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
				["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
				["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
				["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
				["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
			},
		},
	},
}
