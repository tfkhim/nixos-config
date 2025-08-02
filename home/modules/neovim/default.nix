# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2024 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    extraLuaConfig = ''
      -- This module must be loaded first because it contains
      -- global variable setups that must happen before loading
      -- any plugins.
      require("tfkhim.options")
      require("tfkhim.telescope")
      require("tfkhim.treesitter")
      require("tfkhim.flash")
      require("tfkhim.lsp")
      require("tfkhim.completion")
      require("tfkhim.fidget")
      require("tfkhim.neotest")
      require("tfkhim.nvim-tree")
    '';

    plugins =
      with pkgs.vimPlugins;
      let
        telescopePlugins = [
          telescope-nvim
          telescope-fzf-native-nvim
          telescope-ui-select-nvim
        ];
        lspPlugins = [
          nvim-lspconfig
          nvim-lsp-file-operations

          # This is a LUA implementation of a TypeScript LSP that uses
          # tsserver instead of the typescript-language-server proxy
          typescript-tools-nvim

          # This is a Java language plugin with additional functionality
          # which is not present in the nvim-lspconfig jdtls config.
          # See:
          #   https://github.com/mfussenegger/nvim-jdtls
          nvim-jdtls
        ];
        completionPlugins = [
          nvim-cmp
          luasnip
          cmp_luasnip
          cmp-nvim-lsp
        ];
        neotestPlugins = [
          neotest
          neotest-vitest
        ];
      in
      [
        adwaita-nvim
        vim-sleuth
        fidget-nvim
        nvim-treesitter.withAllGrammars
        # Used by different plugins to show icons. E.g. by Telescope to show
        # file type icons in the result list.
        nvim-web-devicons
        flash-nvim
        nvim-tree-lua
      ]
      ++ telescopePlugins
      ++ lspPlugins
      ++ completionPlugins
      ++ neotestPlugins;
  };

  xdg.configFile."nvim/lua".source = ./lua;

  home.packages = with pkgs; [
    fd # recommended by the Telescope plugin
    nil
    rust-analyzer
  ];

  # ripgrep is recommended by the Telescope NeoVim plugin
  programs.ripgrep.enable = true;
}
