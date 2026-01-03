-- This file is part of https://github.com/tfkhim/nixos-config
--
-- Copyright (c) 2024 Thomas Himmelstoss
--
-- This software is subject to the MIT license. You should have
-- received a copy of the license along with this program.

require("nvim-treesitter.configs").setup({
    auto_install = false,

    indent = {
        enable = true,
    },

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = false,
            node_incremental = ";",
            scope_incremental = false,
            node_decremental = ",",
        },
    },
})
