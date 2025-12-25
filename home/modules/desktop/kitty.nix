# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = config.custom.tfkhim.desktops.fonts.monospace.name;
      size = 11;
    };
  };

  programs.kitty.settings = {
    "enable_audio_bell" = "no";

    # Color scheme
    # ============

    "cursor" = "#fcfcfc";
    "cursor_shape" = "beam";

    "foreground" = "#fcfcfc";
    "background" = "#232627";

    "background_opacity" = "1";

    "selection_foreground" = "none";
    "selection_background" = "none";

    # Color table
    # ===========

    # black

    "color0" = "#232627";
    "color8" = "#7f8c8d";

    # red

    "color1" = "#ed1515";
    "color9" = "#c0392b";

    # green

    "color2" = "#11d116";
    "color10" = "#1cdc9a";

    # yellow

    "color3" = "#f67400";
    "color11" = "#fdbc4b";

    # blue

    "color4" = "#1d99f3";
    "color12" = "#3daee9";

    # magenta

    "color5" = "#9b59b6";
    "color13" = "#8e44ad";

    # cyan

    "color6" = "#1abc9c";
    "color14" = "#16a085";

    # white

    "color7" = "#fcfcfc";
    "color15" = "#ffffff";
  };

  programs.kitty.keybindings = {
    "ctrl+shift+t" = "new_os_window_with_cwd";
  };

  programs.kitty.shellIntegration.mode = "no-cursor";
}
