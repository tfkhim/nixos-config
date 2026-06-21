-- This file is part of https://github.com/tfkhim/nixos-config
--
-- Copyright (c) 2026 Thomas Himmelstoss
--
-- This software is subject to the MIT license. You should have
-- received a copy of the license along with this program.

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local buf, filetype = args.buf, args.match

        local language = vim.treesitter.language.get_lang(filetype)

        if not language then
            return
        end

        -- Check if there is a parser for the language
        if not vim.treesitter.language.add(language) then
            return
        end

        -- Enable treesitter highlighting and disable regex syntax
        vim.treesitter.start(buf, language)

        -- Enable treesitter based folding
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldmethod = "expr"

        vim.keymap.set("v", ";", function()
            vim.treesitter.select("parent")
        end, { buffer = buf, desc = "Extend selection to parent" })

        vim.keymap.set("v", ",", function()
            vim.treesitter.select("child")
        end, { buffer = buf, desc = "Restrict selection to child" })
    end,
})
