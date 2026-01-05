# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  imports = [
    ./hyprland-config.nix
    ./screenlocking.nix
    ./wallpaper.nix
  ];

  options.custom.tfkhim.desktops.hyprland = {
    systemdTarget = mkOption {
      description = "Systemd target to bind services exclusive to Hyprland";
      type = types.str;
      default = "hyprland-session.target";
    };
  };
}
