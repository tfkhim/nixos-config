-- This file is part of https://github.com/tfkhim/nixos-config
--
-- Copyright (c) 2024 Thomas Himmelstoss
--
-- This software is subject to the MIT license. You should have
-- received a copy of the license along with this program.

require("flash").setup({
    modes = {
        search = {
            enabled = true,
        },
    },

    search = {
        mode = "search",
    },
})

vim.keymap.set("n", "<Leader>jl", function()
    require("flash").jump()
end)
