# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, ... }:

{
  environment.pathsToLink = [
    "/share/backgrounds"
    "/share/cosmic"
    "/share/cosmic-layouts"
    "/share/cosmic-themes"
  ];

  environment.systemPackages = with pkgs; [
    cosmic-session
    cosmic-comp
    cosmic-applets
    cosmic-applibrary
    cosmic-bg
    config.services.displayManager.cosmic-greeter.package
    cosmic-idle
    cosmic-notifications
    cosmic-osd
    cosmic-panel
    cosmic-settings
    cosmic-settings-daemon
    cosmic-workspaces-epoch

    cosmic-screenshot

    cosmic-icons
    pop-icon-theme

    cosmic-launcher
    pop-launcher

    # Used by cosmic-settings-daemon. Produces a lot of "No such file errors" if missing
    pulseaudio
  ];

  services.graphical-desktop.enable = true;

  programs.xwayland.enable = true;

  # Provides the org.freedesktop.RealtimeKit1 DBus service to
  # XDG Desktop Portal. Without this journalctl contains some
  # warnings due to the missing interface.
  security.rtkit.enable = true;

  xdg = {
    # Required for cosmic-osd
    sounds.enable = true;

    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-cosmic
        xdg-desktop-portal-gtk
      ];
      configPackages = [ pkgs.xdg-desktop-portal-cosmic ];
    };
  };

  systemd = {
    packages = [ pkgs.cosmic-session ];
    user.targets.cosmic-session = {
      wants = [ "xdg-desktop-autostart.target" ];
      before = [ "xdg-desktop-autostart.target" ];
    };
  };

  programs.dconf.enable = true;
  programs.dconf.packages = [ pkgs.cosmic-session ];

  security.polkit.enable = true;

  # Required by the screen lock to unlock the session
  security.pam.services.cosmic-greeter = { };

  # Required by the panel to show the battery charge
  services.upower.enable = true;
}
