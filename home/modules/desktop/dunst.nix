# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # This configuration uses the new recursive icon lookup method. Therefore
  # the icon path isn't needed. But it is important to add the icon package
  # to home.packages. This ensures the Adwaita icon theme ends up in one of
  # the directories in XDG_DATA_DIRS. Dunst uses this environment variable
  # for looking up the icons based on the icon theme name. See:
  # https://github.com/dunst-project/dunst/blob/master/docs/dunst.5.pod

  home.packages = [ pkgs.gnome.adwaita-icon-theme ];

  services.dunst.enable = true;

  services.dunst.settings = {
    global = {
      font = "${config.desktops.fonts.sanSerif.name} 12";

      enable_recursive_icon_lookup = true;
      icon_theme = "Adwaita";
      # Force an emtpy icon path to avoid the very lengthy default value.
      icon_path = lib.mkForce "";

      origin = "top-right";
      offset = "10x10";

      gap_size = 7;

      corner_radius = 7;
      frame_width = 1;
      frame_color = "#242424";

      background = "#000000";
      foreground = "#ffffff";
    };

    urgency_low = {
      timeout = 10;

      # Activate the default_icons when
      # https://github.com/dunst-project/dunst/pull/1081
      # is merged. Sadly right now the icons are too dark.
      # default_icon = "dialog-information-symbolic";
    };

    urgency_normal = {
      timeout = 10;

      # default_icon = "dialog-warning-symbolic";
    };

    urgency_critical = {
      timeout = 0;

      # default_icon = "dialog-error-symbolic";
    };
  };
}
