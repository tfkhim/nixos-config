# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  imports = [
    ./hyprland-config.nix
    ./screenlocking.nix
    ./wallpaper.nix
    ./waybar.nix
  ];
}
