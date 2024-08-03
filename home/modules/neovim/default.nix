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
      require("tfkhim.fidget")
    '';

    plugins = with pkgs.vimPlugins; [
      adwaita-nvim
      vim-sleuth
      fidget-nvim
      nvim-treesitter.withAllGrammars
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      # With the devicons installed Telescope shows file type
      # icons in the result list.
      nvim-web-devicons
      flash-nvim
      nvim-lspconfig
      typescript-tools-nvim
    ];
  };

  xdg.configFile."nvim/lua".source = ./lua;

  home.packages = with pkgs; [
    nil
    rust-analyzer
  ];

  # ripgrep is recommended by the Telescope NeoVim plugin
  programs.ripgrep.enable = true;
}
