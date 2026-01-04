# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ pkgs, lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options.custom.tfkhim.desktops.background = mkOption {
    description = "Image used as the desktop background.";
    type = types.path;
    default = "${pkgs.nixos-artwork.wallpapers.stripes-logo.src}";
  };
}
