# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  pkgs,
  lib,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  imports = [
    ./background.nix
    ./fonts.nix
    ./kitty.nix
    ./services.nix
    ./system-programs.nix
    ./theming.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
    xdg-utils
  ];

  # The portal setup is managed by the system configuration. Currently,
  # the Home Manager configuration hides that setup. Therefore, we need
  # to configure the same portals here as in the system setup. This
  # will hopefully be fixed in the future.
  # See:
  # https://github.com/nix-community/home-manager/issues/7124
  xdg.portal.extraPortals = mkIf (osConfig != null) osConfig.xdg.portal.extraPortals;
}
