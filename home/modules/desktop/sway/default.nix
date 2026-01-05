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
    ./screenlocking.nix
    ./sway-config.nix
  ];

  options.custom.tfkhim.desktops.sway = {
    systemdTarget = mkOption {
      description = "Systemd target to bind services exclusive to Sway";
      type = types.str;
      default = "sway-session.target";
    };
  };
}
