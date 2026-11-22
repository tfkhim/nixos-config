-- This file is part of https://github.com/tfkhim/nixos-config
--
-- Copyright (c) 2026 Thomas Himmelstoss
--
-- This software is subject to the MIT license. You should have
-- received a copy of the license along with this program.

local gitsigns = require("gitsigns")
local diffview = require("diffview")

gitsigns.setup({
    on_attach = function(bufnr)
        local function map(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { desc = desc, buffer = bufnr })
        end

        map("n", "]c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
            else
                gitsigns.nav_hunk("next")
            end
        end, "Navigate to next hunk")

        map("n", "[c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
            else
                gitsigns.nav_hunk("prev")
            end
        end, "Navigate to previous hunk")

        map("n", "<leader>gcp", gitsigns.preview_hunk, "[G]it [C]ange [P]review")
        map("n", "<leader>gcs", gitsigns.stage_hunk, "[G]it [C]ange [S]tage")
        map("n", "<leader>gcr", gitsigns.reset_hunk, "[G]it [C]ange [R]eset")
        map("n", "<leader>gbs", gitsigns.stage_buffer, "[G]it [B]uffer [S]tage")

        map("n", "<leader>gbt", gitsigns.blame, "[G]it [B]lame [T]oggle")
    end,
})

diffview.setup()

vim.keymap.set("n", "<Leader>gdo", diffview.open, { desc = "[G]it [D]iff [O]pen" })
vim.keymap.set("n", "<Leader>gdc", diffview.close, { desc = "[G]it [D]iff [C]lose" })
