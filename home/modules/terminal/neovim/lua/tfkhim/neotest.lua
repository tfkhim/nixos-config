-- This file is part of https://github.com/tfkhim/nixos-config
--
-- Copyright (c) 2025 Thomas Himmelstoss
--
-- This software is subject to the MIT license. You should have
-- received a copy of the license along with this program.

local neotest = require("neotest")

neotest.setup({
    adapters = {
        require("neotest-vitest"),
    },
})

local map = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { desc = desc })
end

map("<leader>tn", neotest.run.run, "Run [n]earest test")
map("<leader>tf", function()
    neotest.run.run(vim.fn.expand("%"))
end, "Run tests in current [f]ile")
map("<leader>tl", neotest.run.run_last, "Run [l]ast test again")
map("<leader>to", function()
    neotest.output.open({ enter = true })
end, "Open test [o]utput")
map("<leader>ts", neotest.summary.toggle, "Toggle test [s]ummary")
