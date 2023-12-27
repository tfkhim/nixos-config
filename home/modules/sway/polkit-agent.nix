# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ pkgs, ... }:

{
  home.packages = [
    pkgs.mate.mate-polkit
  ];

  systemd.user.services.mate-polkit-agent = {
    Unit = {
      Description = "MATE polkit agent";
      PartOf = [ "graphical-session.target" ];
    };


    Service = {
      Type = "simple";
      Restart = "always";
      ExecStart = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
