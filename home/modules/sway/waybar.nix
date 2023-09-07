# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, ... }:
let
  # Unicode 2004: Three-Per-Em Space
  iconSeparator = " ";
  # Unicode 2003: Em Space
  segmentSeparator = " ";

  pavucontrol = lib.getExe pkgs.pavucontrol;

  makeBatteryConfig = bat: {
    inherit bat;
    states = {
      warning = 30;
    };
    format = "<b>{capacity}%</b>${iconSeparator}{icon}";
    format-charging = "<b>{capacity}%</b>${iconSeparator}󰃨";
    format-plugged = "<b>{capacity}%</b>${iconSeparator}";
    format-icons = [ "" "" "" "" "" ];
  };
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    style = with config.desktops.sway.fonts;
      ''
        * {
          font-family: "${sanSerif.name}", "${symbols.name}";
        }
      ''
      + builtins.readFile ./waybar-style.css;
  };

  programs.waybar.settings = [{
    height = 30;
    spacing = 4;
    modules-left = [ "sway/workspaces" "sway/mode" ];
    modules-center = [ "sway/window" ];
    modules-right = [
      "tray"
      "pulseaudio"
      "network"
      "cpu"
      "memory"
      "backlight"
      "battery"
      "battery#bat1"
      "clock#date"
      "clock#time"
    ];
    "sway/workspaces" = {
      format = "<b>{}</b>";
    };
    "sway/mode" = {
      format = "<b>{}</b>";
    };
    "sway/window" = {
      format = "<b>{}</b>";
    };
    tray = {
      spacing = 10;
    };
    pulseaudio = {
      format = "<b>{volume}%</b>${iconSeparator}{icon}${segmentSeparator}{format_source}";
      format-bluetooth = "<b>{volume}%</b>${iconSeparator}{icon}${segmentSeparator}{format_source}";
      format-bluetooth-muted = "<b>0%</b>${iconSeparator}󰖁${segmentSeparator}{format_source}";
      format-muted = "<b>0%</b>${iconSeparator}󰖁${segmentSeparator}{format_source}";
      format-source = "<b>{volume}%</b>${iconSeparator}";
      format-source-muted = "<b>0%</b>${iconSeparator}";
      format-icons = {
        headphone = "󰋋";
        hands-free = "󰋎";
        headset = "󰋎";
        phone = "";
        portable = "";
        car = "";
        default = [ "" "" "" ];
      };
      on-click = pavucontrol;
    };
    network = {
      format-wifi = "<b>{ifname} ({signalStrength}%)</b>${iconSeparator}";
      format-ethernet = "<b>{ifname}</b>${iconSeparator}󰈀";
      format-linked = "<b>{ifname} (No IP)</b>${iconSeparator}󰈀";
      format-disconnected = "<b>Disconnected</b>${iconSeparator}󰌺";
      tooltip-format = "{ipaddr}/{cidr}";
    };
    cpu = {
      format = "<b>{usage}%</b>${iconSeparator}";
    };
    memory = {
      format = "<b>{}%</b>${iconSeparator}";
    };
    backlight = {
      format = "<b>{percent}%</b>${iconSeparator}{icon}";
      format-icons = [ "󱩐" "󱩒" "󰛨" ];
    };
    battery = makeBatteryConfig "BAT0";
    "battery#bat1" = makeBatteryConfig "BAT1";
    "clock#date" = {
      tooltip-format = "<big><b>{:%Y %B}</b>\n\n<tt>{calendar}</tt></big>";
      format = "<b>{:%d.%m.%Y}</b>${iconSeparator}";
    };
    "clock#time" = {
      format = "<b>{:%H:%M}</b>${iconSeparator}";
    };
  }];
}
