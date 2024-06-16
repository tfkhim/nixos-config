# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2024 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, ... }:
let
  inherit (lib)
    types
    mkOption
    mkIf
    getExe
    optional
    concatStringsSep
    elem;

  cfg = config.desktops.hyprland;
  finalHyprlandPackage = config.wayland.windowManager.hyprland.finalPackage;

  kanshiCfg = config.services.kanshi;
in
{
  imports = [
    ./base-desktop.nix
    ./modules/hyprland/hyprland-config.nix
    ./modules/hyprland/screenlocking.nix
    ./modules/hyprland/wallpaper.nix
    ./modules/hyprland/waybar.nix
    ./modules/desktop/kitty.nix
    ./modules/desktop/mate-polkit-agent.nix
    ./modules/desktop/nwg-bar.nix
    ./modules/desktop/swaync.nix
    ./modules/desktop/theming.nix
  ];

  options.desktops.hyprland = {
    startOnTTYLogin = mkOption {
      description = ''
        Start Hyprland immediately after logging in at tty1.

        Currently this only works if the users login shell is ZSH and the
        ZSH configuration is also managed by home-manager.
      '';
      type = types.bool;
      default = false;
    };

    disableHardwareCursors = mkOption {
      description = ''
        Disable hardware cursors which might not work on Nvidia GPUs.

        See: https://wiki.hyprland.org/Nvidia/
      '';
      type = types.bool;
      default = false;
    };

    keyboardFocusFollowsMouse = mkOption {
      description = ''
        If true (default) the mouse movement will also change the keyboard focus.
        If set to false only a mouse click will change the keyboard focus.

        See: https://wiki.hyprland.org/Configuring/Variables/#follow-mouse-cursor
      '';
      type = types.bool;
      default = true;
    };
  };

  config = {
    # Add the kanshi package to be able to easily use
    # kanshictl for reloading the configuration and
    # switching to a different profile.
    home.packages = mkIf kanshiCfg.enable [
      kanshiCfg.package
    ];

    wayland.windowManager.hyprland.enable = true;
    services.sway-notification-center.enable = true;

    # Screensharing on Wayland is done by XDG Desktop Portal and Pipewire.
    # The programs.hyprland.enable = true setting already installs the
    # Hyprland backand for xdg-desktop-portal.
    # See:
    # * https://wiki.archlinux.org/title/Screen_capture#Via_the_WebRTC_protocol
    # * https://wiki.archlinux.org/title/PipeWire#WebRTC_screen_sharing
    # * https://wiki.archlinux.org/title/XDG_Desktop_Portal#List_of_backends_and_interfaces
    # * https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/programs/hyprland.nix#L66
    xdg.portal =
      let
        finalPortalPackage = pkgs.xdg-desktop-portal-hyprland.override {
          hyprland = finalHyprlandPackage;
        };
      in
      {
        enable = true;
        extraPortals = [ finalPortalPackage ];
        configPackages = [ finalHyprlandPackage ];
      };

    programs.zsh.loginExtra = mkIf cfg.startOnTTYLogin ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        ${if cfg.disableHardwareCursors then "export WLR_NO_HARDWARE_CURSORS=1" else ""}
        exec ${getExe finalHyprlandPackage}
      fi
    '';

    services.kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";
    };

    # Also refer to the base-desktop.nix file in the system
    # configuration for the required gcr DBus service.
    services.gpg-agent.pinentryPackage = pkgs.pinentry-gnome3;
  };
}
