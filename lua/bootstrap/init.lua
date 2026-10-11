-- check if git exists
if vim.fn.executable("git") == 0 then
	vim.notify("Git is required to install plugins", vim.log.levels.ERROR)
	return
end
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- check if lazy.nvim exists
if vim.fn.isdirectory(lazypath) == 0 then
	print("Installing lazy.nvim...")
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "plugins" },
		{ import = "plugins.lang" }, -- language extras
	},
	defaults = { lazy = false },
	change_detection = { enabled = false }, -- handled by lua/reload
})
