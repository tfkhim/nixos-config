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
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  home.packages = with pkgs; [
    delta
  ];
}
