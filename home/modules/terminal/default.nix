# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./ssh
    ./gpg.nix
    ./git.nix
    ./neovim
  ];

  home.packages = with pkgs; [
    file
    zip
    unzip
    fd
  ];

  programs.bottom.enable = true;

  programs.ripgrep.enable = true;

  programs.bat.enable = true;
}
