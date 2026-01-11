# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, ... }:
let
  systemdTarget = config.custom.tfkhim.desktops.minimal-wayland-desktop-extensions.systemdTarget;
in
{
  home.packages = [
    pkgs.mate.mate-polkit
  ];

  systemd.user.services.mate-polkit-agent = {
    Unit = {
      Description = "MATE polkit agent";
      PartOf = [ systemdTarget ];
      After = [ systemdTarget ];
    };

    Service = {
      Type = "simple";
      Restart = "always";
      ExecStart = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
    };

    Install = {
      WantedBy = [ systemdTarget ];
    };
  };
}
