-- This file is part of https://github.com/tfkhim/nixos-config
--
-- Copyright (c) 2024 Thomas Himmelstoss
--
-- This software is subject to the MIT license. You should have
-- received a copy of the license along with this program.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd("colorscheme adwaita")

vim.opt.number = true
vim.opt.relativenumber = true

vim.keymap.set("n", "<leader>tr", function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "[T]oggle [R]elative numbers" })

vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

vim.opt.updatetime = 500

vim.opt.timeoutlen = 600

vim.opt.inccommand = "split"

vim.opt.cursorline = true

vim.opt.scrolloff = 10

-- This setting makes tab completion behave more similar to the
-- completion in the shell. The first press completes as much as
-- possible and also shows a menu with candidates. The follow-up
-- key presses then iterate through the candiate list.
vim.opt.wildmode = "longest:full,full"
vim.opt.wildmenu = true

vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>")

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
