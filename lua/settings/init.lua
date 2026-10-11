local opt = vim.opt

-- Generall
opt.clipboard = "unnamedplus"
opt.swapfile = false
opt.backup = false
opt.linebreak = true -- Wrap long lines at a character in 'breakat'
opt.smoothscroll = true
opt.undofile = true
opt.tabstop = 2 -- Number of spaces tabs count for
opt.shiftwidth = 2 -- Size of an indent
opt.number = true
opt.ignorecase = true -- Ignore case
opt.relativenumber = true -- Relative line numbers
opt.sidescrolloff = 8 -- Columns of context
opt.laststatus = 3 -- global statusline
opt.foldmethod = "expr"
opt.foldtext = ""
vim.o.ch = 0
opt.winminwidth = 5 -- Minimum window width
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.wrap = false -- Don't wrap lines

vim.filetype.add({
	extension = {
		arb = "json",
	},
})
