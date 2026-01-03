-- This file is part of https://github.com/tfkhim/nixos-config
--
-- Copyright (c) 2024 Thomas Himmelstoss
--
-- This software is subject to the MIT license. You should have
-- received a copy of the license along with this program.

require("lsp-file-operations").setup()

local client_capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp_file_capabilities = require("lsp-file-operations").default_capabilities()
local capabilities = vim.tbl_deep_extend("force", client_capabilities, cmp_lsp_capabilities, lsp_file_capabilities)

vim.lsp.config("*", { capabilities = capabilities })
vim.lsp.enable({ "rust_analyzer", "nil_ls", "kotlin_language_server" })

require("typescript-tools").setup({ capabilities = capabilities })

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("tfkhim-java-lsp", { clear = true }),
    pattern = "java",
    callback = function(event)
        require("jdtls").start_or_attach({
            cmd = { "jdtls" },
            capabilities = capabilities,
        })
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("tfkhim-lsp-attach", { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        local supports = function(method)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            return client and client.supports_method(method)
        end

        map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
        map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
        map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        if supports(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
        end

        if supports(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("tfkhim-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("tfkhim-lsp-detach", { clear = true }),
                callback = function(detach_event)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({ group = "tfkhim-lsp-highlight", buffer = detach_event.buf })
                end,
            })
        end
    end,
})
