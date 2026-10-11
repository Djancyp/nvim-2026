vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- ForceQuit
map("n", "<C-s>", "<cmd>noa w!<CR>", { desc = "Force write" })
map("n", "<C-q>", "<cmd>:q!<CR>", { desc = "Force quit" })
map("i", "jk", "<Esc>", { desc = "Escape from insert mode" })
map("i", "<C-c>", "<Esc>", { desc = "Escape from insert mode" })
map("t", "<C-space>", "<Esc>", { desc = "Escape from insert mode from terminal" })
--
map("n", "<leader>/", ":nohlsearch<CR>", { desc = "No highlight" })

-- Better up/down movement
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move lines up and down
map("v", "J", ":m .+1<CR>==", { desc = "Move line down" })
map("v", "K", ":m .-2<CR>==", { desc = "Move line up" })

-- Resize window using <Ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move up" })
map("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move down" })
map("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move up" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Switch to other buffer" })
map("n", "<leader>`", "<cmd>e #<CR>", { desc = "Switch to other buffer" })

-- Saner behavior of n and N
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Previous search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Previous search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Previous search result" })

-- Add undo break-points
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", ";", ";<C-g>u")

-- Clear search with <Esc>
map({ "i", "n" }, "<Esc>", "<cmd>noh<CR><Esc>", { desc = "Escape and clear search highlight" })

-- Remap default keybindings
map("n", "J", "mzJ`z")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "<C-f>", "<C-f>zz")
map("n", "<C-b>", "<C-b>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next location list item" })
map("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Previous location list item" })

-- Move to window using <Ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

map("n", "sa", "ggVG", { desc = "Insert new line below" })

-- Split window vertically and center cursor
map("n", "<C-w><C-v>", "<C-w>v<C-w>w zz", { desc = "Split window vertically and jump" })

-- root save
map("n", "<leader>ss", "<cmd>:lua require'utils'.sudo_write()<CR>", { desc = "Sudo write" })

-- Split window horizontally and center cursor
map("n", "<C-w><C-s>", "<C-w>s<C-w>w zz", { desc = "Split window horizontally and jump" })

map("n", "K", vim.lsp.buf.hover, { desc = "LSP Format" })
map("n", "gj", function()
	local next = vim.diagnostic.get_next({ severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN } })
	if not next then
		return
	end
	vim.diagnostic.jump({
		diagnostic = next,
		float = true,
	})
end, { desc = "LSP Format" })
map("n", "gk", function()
	local next = vim.diagnostic.get_prev({ severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN } })
	if not next then
		return
	end
	vim.diagnostic.jump({
		diagnostic = next,
		float = true,
	})
end, { desc = "LSP Format" })

-- Development purpose
map("n", "<leader>ro", function()
	-- get input plugin name
	local plugin = vim.fn.input("Plugin name: ")
	if plugin == "" then
		return
	end
	local lazy = require("lazy.core.loader")

	lazy.reload(plugin)
end, { desc = "Reload config" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
