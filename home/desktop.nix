# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, lib, ... }:
let
  inherit (lib)
    types
    mkOption
    mkMerge
    mkIf
    ;

  cfg = config.custom.tfkhim.desktops;
in
{
  imports = [
    ./cli-user.nix
    ./modules/desktop/base
    ./modules/desktop/hyprland
    ./modules/desktop/sway
    ./modules/desktop/cosmic
    ./modules/desktop/minimal-wayland-desktop-extensions
    ./modules/misc
  ];

  options.custom.tfkhim.desktops = {
    startOnTTYLogin = mkOption {
      description = ''
        Which desktop environment to start after logging in at tty1.

        Currently this only works if the users login shell is ZSH and the
        ZSH configuration is also managed by home-manager.
      '';
      type = types.enum [
        "hyprland"
        "sway"
        "cosmic"
      ];
    };
  };

  config = mkMerge [
    {
      wayland.windowManager.hyprland = {
        enable = true;

        # The Systemd handling is already done by UWSM. Therefore,
        # we must disable this option to avoid conflicts.
        # See:
        #   https://wiki.hypr.land/Useful-Utilities/Systemd-start/#uwsm
        systemd.enable = false;
      };

      wayland.windowManager.sway = {
        enable = true;
        package = null;
      };

      custom.tfkhim.services.sway-notification-center.enable = true;
    }

    (mkIf (cfg.startOnTTYLogin == "hyprland") {
      programs.zsh.loginExtra = ''
        if [ "$(tty)" = "/dev/tty1" ] && uwsm check may-start; then
          exec uwsm start -- hyprland-uwsm.desktop
        fi
      '';
    })

    (mkIf (cfg.startOnTTYLogin == "sway") {
      programs.zsh.loginExtra = ''
        if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec sway
        fi
      '';
    })

    (mkIf (cfg.startOnTTYLogin == "cosmic") {
      programs.zsh.loginExtra = ''
        if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec start-cosmic
        fi
      '';
    })
  ];
}
