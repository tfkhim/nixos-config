-- This file is part of https://github.com/tfkhim/nixos-config
--
-- Copyright (c) 2024 Thomas Himmelstoss
--
-- This software is subject to the MIT license. You should have
-- received a copy of the license along with this program.

local flash = require("flash")

flash.setup({
    label = {
        uppercase = false,
    },
    modes = {
        search = {
            enabled = false,
        },
        char = {
            enabled = false,
        },
    },

    search = {
        mode = "search",
    },
})

local function jumpToWord()
    -- See: https://github.com/folke/flash.nvim?tab=readme-ov-file#-examples

    local function format(opts)
        return {
            { opts.match.label1, "FlashMatch" },
            { opts.match.label2, "FlashLabel" },
        }
    end

    flash.jump({
        search = { mode = "search" },
        label = { after = false, before = { 0, 0 }, uppercase = false, format = format },
        pattern = [[\<]],
        action = function(match, state)
            state:hide()
            flash.jump({
                search = { max_length = 0 },
                highlight = { matches = false },
                label = { format = format },
                matcher = function(win)
                    -- limit matches to the current label
                    return vim.tbl_filter(function(m)
                        return m.label == match.label and m.win == win
                    end, state.results)
                end,
                labeler = function(matches)
                    for _, m in ipairs(matches) do
                        m.label = m.label2 -- use the second label
                    end
                end,
            })
        end,
        labeler = function(matches, state)
            local labels = state:labels()
            for m, match in ipairs(matches) do
                match.label1 = labels[math.floor((m - 1) / #labels) + 1]
                match.label2 = labels[(m - 1) % #labels + 1]
                match.label = match.label1
            end
        end,
    })
end

vim.keymap.set("n", "gw", jumpToWord)

vim.keymap.set("n", "<Leader>jl", function()
    require("flash").jump()
end)

vim.keymap.set("n", "<Leader>vt", function()
    require("flash").treesitter()
end)
