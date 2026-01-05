# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2024 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) types mkOption mkIf;

  cfg = config.custom.tfkhim.desktops.hyprland;
in
{
  imports = [
    ./cli-user.nix
    ./modules/desktop/base
    ./modules/desktop/hyprland
    ./modules/desktop/minimal-wayland-desktop-extensions
    ./modules/misc
  ];

  options.custom.tfkhim.desktops.hyprland = {
    startOnTTYLogin = mkOption {
      description = ''
        Start Hyprland immediately after logging in at tty1.

        Currently this only works if the users login shell is ZSH and the
        ZSH configuration is also managed by home-manager.
      '';
      type = types.bool;
      default = false;
    };
  };

  config = {
    wayland.windowManager.hyprland.enable = true;

    # The Systemd handling is already done by UWSM. Therefore,
    # we must disable this option to avoid conflicts.
    # See:
    #   https://wiki.hypr.land/Useful-Utilities/Systemd-start/#uwsm
    wayland.windowManager.hyprland.systemd.enable = false;

    custom.tfkhim.services.sway-notification-center.enable = true;

    programs.zsh.loginExtra = mkIf cfg.startOnTTYLogin ''
      if uwsm check may-start; then
        exec uwsm start -- hyprland-uwsm.desktop
      fi
    '';

    # Also refer to the base-desktop.nix file in the system
    # configuration for the required gcr DBus service.
    services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
  };
}
