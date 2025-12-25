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
  image = config.custom.tfkhim.desktops.background;
in
{
  xdg.configFile."hypr/hyprpaper.conf".text = lib.hm.generators.toHyprconf {
    attrs = {
      preload = image;
      wallpaper = ", ${image}";
      splash = false;
      ipc = "off";
    };
  };

  systemd.user.services.hyprpaper = {
    Unit = {
      Description = "Wallpaper daemon for Hyprland";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };

    Service = {
      Type = "simple";
      Restart = "always";
      ExecStart = lib.getExe pkgs.hyprpaper;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
