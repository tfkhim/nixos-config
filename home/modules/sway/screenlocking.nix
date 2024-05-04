# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf;
  inherit (config.desktops.programs) swaymsg;

  swaylock = config.desktops.programs.swaylock;
  swaylockEnabled = swaylock != null;

  pgrep = "${pkgs.procps}/bin/pgrep";
  outputControlEnabled = swaymsg != null;
  turnOffOutputs = "${swaymsg} 'output * dpms off'";
  turnOnOutputs = "${swaymsg} 'output * dpms on'";
  swaylockIsRunning = "${pgrep} -x '${builtins.baseNameOf swaylock}'";
in
{
  programs.swaylock = mkIf swaylockEnabled {
    enable = true;

    settings = {
      daemonize = true;
      image = config.desktops.background;
      font = config.desktops.fonts.sanSerif.name;
    };
  };

  services.swayidle = mkIf swaylockEnabled {
    enable = true;

    timeouts = [
      {
        timeout = 300;
        command = swaylock;
      }
      (mkIf outputControlEnabled {
        timeout = 310;
        command = turnOffOutputs;
      })
      (mkIf outputControlEnabled {
        timeout = 10;
        command = "${swaylockIsRunning} && ${turnOffOutputs}";
        resumeCommand = turnOnOutputs;
      })
    ];

    events = [
      { event = "before-sleep"; command = swaylock; }
    ];
  };
}
