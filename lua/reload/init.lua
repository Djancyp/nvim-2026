-- Hot reload config files: auto on save, or <leader>rr / :ReloadConfig
local M = {}

local config_dir = vim.fn.stdpath("config")

-- Plugin names defined in a lazy spec file
local function spec_names(path)
	local ok, spec = pcall(dofile, path)
	local names = {}
	local function collect(s)
		if type(s) ~= "table" then
			return
		end
		if type(s[1]) == "string" then
			names[#names + 1] = s.name or s[1]:match("[^/]+$"):gsub("%.git$", "")
			for _, dep in ipairs(s.dependencies or {}) do
				collect(dep)
			end
		else
			for _, child in ipairs(s) do
				collect(child)
			end
		end
	end
	if ok then
		collect(spec)
	end
	return names
end

local function reload_plugins(names)
	local Config = require("lazy.core.config")
	local Loader = require("lazy.core.loader")
	require("lazy.core.plugin").load() -- re-read specs so new opts are used
	local lsp = false
	for _, name in ipairs(names) do
		if Config.plugins[name] then
			Loader.reload(name)
			lsp = lsp or name:find("lspconfig") ~= nil
		end
	end
	-- running clients keep old settings until restarted
	if lsp and #vim.lsp.get_clients() > 0 then
		vim.cmd("lsp restart")
	end
end

---@param path string absolute file path
---@return boolean reloaded
function M.reload_file(path)
	if path:find(config_dir, 1, true) ~= 1 then
		return false
	end
	local rel = path:sub(#config_dir + 2)

	if rel == "init.lua" or rel:find("^lua/bootstrap/") then
		vim.notify(rel .. ": restart nvim to apply", vim.log.levels.WARN)
		return false
	elseif rel:find("^lua/plugins/") then
		reload_plugins(spec_names(path))
	elseif rel:find("^lua/") then
		local mod = rel:gsub("^lua/", ""):gsub("%.lua$", ""):gsub("/init$", ""):gsub("/", ".")
		package.loaded[mod] = nil
		require(mod)
	else
		vim.cmd.source(path)
	end
	vim.notify("Reloaded " .. rel)
	return true
end

function M.reload_all()
	local names = {}
	for name, type in vim.fs.dir(config_dir .. "/lua", { depth = 3 }) do
		local path = config_dir .. "/lua/" .. name
		if type == "file" and name:find("%.lua$") then
			if name:find("^plugins/") then
				vim.list_extend(names, spec_names(path))
			elseif not name:find("^bootstrap/") and not name:find("^reload/") then
				M.reload_file(path)
			end
		end
	end
	reload_plugins(names)
	vim.notify("Reloaded config")
end

vim.api.nvim_create_autocmd("BufWritePost", {
	group = vim.api.nvim_create_augroup("user-reload-config", { clear = true }),
	pattern = { "*.lua", "*.vim" },
	callback = function(ev)
		M.reload_file(vim.fn.fnamemodify(ev.file, ":p"))
	end,
})

vim.api.nvim_create_user_command("ReloadConfig", function(cmd)
	if cmd.args ~= "" then
		M.reload_file(vim.fn.fnamemodify(cmd.args, ":p"))
	elseif not M.reload_file(vim.api.nvim_buf_get_name(0)) then
		M.reload_all()
	end
end, { nargs = "?", complete = "file", desc = "Reload current config file (or all)" })

vim.keymap.set("n", "<leader>rr", "<cmd>ReloadConfig<CR>", { desc = "Reload config" })
vim.keymap.set("n", "<leader>rR", M.reload_all, { desc = "Reload all config" })

return M
