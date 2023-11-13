# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  imports = [
    ./base-desktop.nix
  ];

  programs.sway = {
    enable = true;
    # This module assumes that other required tools (e.g.
    # swaylock or swayidle) are installed through the home
    # manager configuration. This avoids installing packages
    # that are not used by the users Sway configuration.
    extraPackages = [ ];
  };

  # Screensharing on Wayland is done by XDG Desktop Portal and Pipewire.
  # Furthermore xdg-desktop-portal requires the wlroots backend for Sway.
  # See:
  # * https://wiki.archlinux.org/title/Screen_capture#Via_the_WebRTC_protocol
  # * https://wiki.archlinux.org/title/PipeWire#WebRTC_screen_sharing
  # * https://wiki.archlinux.org/title/XDG_Desktop_Portal#List_of_backends_and_interfaces
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  # Provides the org.freedesktop.RealtimeKit1 DBus service to
  # XDG Desktop Portal. Without this journalctl contains some
  # warnings due to the missing interface.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };
}
