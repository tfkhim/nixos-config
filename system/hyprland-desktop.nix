# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2024 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  imports = [
    ./base-desktop.nix
  ];

  security.polkit.enable = true;

  hardware.opengl.enable = true;

  # Provides the org.freedesktop.RealtimeKit1 DBus service to
  # XDG Desktop Portal. Without this journalctl contains some
  # warnings due to the missing interface.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  programs.dconf.enable = true;

  programs.xwayland.enable = true;
}
