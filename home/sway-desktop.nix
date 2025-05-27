# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
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
  inherit (lib)
    types
    mkOption
    mkIf
    optional
    ;

  cfg = config.desktops.sway;

  swayCmd = config.desktops.programs.sway;
  kanshiCfg = config.services.kanshi;
in
{
  imports = [
    ./base-desktop.nix
    ./modules/sway/sway-config.nix
    ./modules/sway/waybar.nix
    ./modules/sway/screenlocking.nix
    ./modules/desktop/kitty.nix
    ./modules/desktop/mate-polkit-agent.nix
    ./modules/desktop/nwg-bar.nix
    ./modules/desktop/swaync.nix
    ./modules/desktop/theming.nix
  ];

  options.desktops.sway = {
    startOnTTYLogin = mkOption {
      description = ''
        Start sway immediately after logging in at tty1.

        Currently this only works if the users login shell is ZSH and the
        ZSH configuration is also managed by home-manager. Furthermore,
        desktops.programs.sway mustn't be `null`.
      '';
      type = types.bool;
      default = false;
    };
  };

  config = {
    home.packages =
      with pkgs;
      [ ]
      ++ [ wl-clipboard ]
      # Add the kanshi package to be able to easily use
      # kanshictl for reloading the configuration and
      # switching to a different profile.
      ++ optional kanshiCfg.enable kanshiCfg.package;

    wayland.windowManager.sway = {
      enable = true;
      package = null;
    };

    services.sway-notification-center.enable = true;

    programs.zsh.loginExtra =
      let
        writeLoginScript = cfg.startOnTTYLogin && swayCmd != null;
      in
      mkIf writeLoginScript ''
        if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec ${swayCmd}
        fi
      '';

    services.kanshi.enable = true;

    # Also refer to the base-desktop.nix file in the system
    # configuration for the required gcr DBus service.
    services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
  };
}
