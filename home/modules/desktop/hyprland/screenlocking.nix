# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2024 Thomas Himmelstoss
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
  inherit (lib) getExe;
  inherit (config.custom.tfkhim.desktops.programs) loginctl;

  hyprlock = getExe config.programs.hyprlock.package;
  hyprlockRunning = "${pkgs.procps}/bin/pidof hyprlock";
  hyprctl = "${config.wayland.windowManager.hyprland.finalPackage}/bin/hyprctl";
  lockSession = "${loginctl} lock-session";
  turnOffOutputs = "${hyprctl} dispatch dpms off";
  turnOnOutputs = "${hyprctl} dispatch dpms on";
in
{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "${hyprlockRunning} || ${hyprlock} --grace 2";
        before_sleep_cmd = lockSession;
      };

      listener = [
        {
          timeout = 300;
          on-timeout = lockSession;
        }
        {
          timeout = 310;
          on-timeout = turnOffOutputs;
          on-resume = turnOnOutputs;
        }
        {
          timeout = 10;
          on-timeout = "${hyprlockRunning} && ${turnOffOutputs}";
          on-resume = turnOnOutputs;
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        ignore_empty_input = true;
      };

      background = {
        monitor = "";
        path = config.custom.tfkhim.desktops.background;
      };

      input-field = {
        monitor = "";
        size = "250, 50";
        placeholder_text = "Password";

        position = "0, -20";
        halign = "center";
        valign = "center";

        outline_thickness = 2;
        outer_color = "rgb(50A2AF)";
        inner_color = "rgb(2A6D95)";
        font_color = "rgb(FFFFFF)";
      };

      animations = {
        animation = [
          "fadeOut,0,0,default"
          "inputFieldColors,0,0,default"
        ];
      };
    };
  };
}
