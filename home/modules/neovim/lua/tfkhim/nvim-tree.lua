-- This file is part of https://github.com/tfkhim/nixos-config
--
-- Copyright (c) 2025 Thomas Himmelstoss
--
-- This software is subject to the MIT license. You should have
-- received a copy of the license along with this program.

require("nvim-tree").setup()

vim.keymap.set("n", "<leader>et", require("nvim-tree.api").tree.toggle, { desc = "[E]xplorer: [T]oggle" })

vim.keymap.set("n", "<leader>ef", function()
    require("nvim-tree.api").tree.find_file({ open = true, focus = true })
end, { desc = "[E]xplorer: Show [f]ile" })
