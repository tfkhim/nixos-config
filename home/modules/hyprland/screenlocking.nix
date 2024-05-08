# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2024 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, ... }:
let
  inherit (lib) getExe;

  hyprlock = getExe pkgs.hyprlock;
  hyprlockRunning = "${pkgs.procps}/bin/pidof hyprlock";
  hyprctl = "${config.wayland.windowManager.hyprland.finalPackage}/bin/hyprctl";
  lockSession = "${config.desktops.programs.loginctl} lock-session";
  turnOffOutputs = "${hyprctl} dispatch dpms off";
  turnOnOutputs = "${hyprctl} dispatch dpms on";
in
{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "${hyprlockRunning} || ${hyprlock}";
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

  xdg.configFile."hypr/hyprlock.conf".text = lib.hm.generators.toHyprconf {
    attrs = {
      general = {
        no_fade_out = true;
        ignore_empty_input = true;
        grace = 2;
      };

      background = {
        monitor = "";
        path = config.desktops.background;
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
    };
  };
}
