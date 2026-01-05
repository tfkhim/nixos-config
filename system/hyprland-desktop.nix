# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

let
  uwsmSessionTarget = "wayland-session@hyprland\\x2duwsm.desktop.target";
in
{
  imports = [
    ./base-desktop.nix
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Adding the hyprland-session.target allows the auxiliary
  # services (e.g. hypridle) to depend on the same target
  # no matter which Systemd integration approach was chosen.
  systemd.user.targets.hyprland-session = {
    description = "Hyprland compositor session";
    documentation = [ "man:systemd.special(7)" ];
    wants = [ "graphical-session-pre.target" ];
    wantedBy = [ uwsmSessionTarget ];
    bindsTo = [ "graphical-session.target" ];
    after = [
      uwsmSessionTarget
      "graphical-session-pre.target"
    ];
  };
}
