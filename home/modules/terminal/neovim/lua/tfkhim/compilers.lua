-- This file is part of https://github.com/tfkhim/nixos-config
--
-- Copyright (c) 2026 Thomas Himmelstoss
--
-- This software is subject to the MIT license. You should have
-- received a copy of the license along with this program.

local function has_tsc_installed_with_npm(path)
    return vim.fn.executable("npx") == 1
        and vim.system({ "npx", "tsc", "--version" }, { cwd = vim.fs.dirname(path) }):wait().code == 0
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("tfkhim-typescript-compiler", { clear = true }),
    pattern = { "typescript", "typescriptreact" },
    callback = function(event)
        local path = vim.api.nvim_buf_get_name(event.buf)

        vim.b[event.buf].tsc_makeprg = has_tsc_installed_with_npm(path) and "npx tsc --noEmit" or "tsc --noEmit"

        vim.api.nvim_buf_call(event.buf, function()
            vim.cmd("compiler tsc")
        end)
    end,
})
