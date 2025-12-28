# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2025 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  imports = [
    ./base-desktop.nix
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
}
