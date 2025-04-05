-- This file is part of https://github.com/tfkhim/nixos-config
--
-- Copyright (c) 2024 Thomas Himmelstoss
--
-- This software is subject to the MIT license. You should have
-- received a copy of the license along with this program.

require("flash").setup({
    label = {
        uppercase = false,
    },
    modes = {
        search = {
            enabled = false,
        },
        char = {
            highlight = {
                backdrop = false,
            },
        },
    },

    search = {
        mode = "search",
    },
})

vim.keymap.set("n", "<Leader>jl", function()
    require("flash").jump()
end)

vim.keymap.set("n", "<Leader>vt", function()
    require("flash").treesitter()
end)
