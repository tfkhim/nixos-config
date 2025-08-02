# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ pkgs, ... }:

{
  imports = [
    ./modules/base.nix
    ./modules/zsh.nix
    ./modules/starship.nix
    ./modules/ssh
    ./modules/gpg.nix
    ./modules/git.nix
    ./modules/neovim
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
