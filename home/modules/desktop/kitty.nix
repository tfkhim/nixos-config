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
      name = config.desktops.fonts.monospace.name;
      size = 11;
    };
  };

  programs.kitty.settings = {
    "enable_audio_bell" = "no";

    # Color scheme
    # ============

    "cursor" = "#fcfcfc";

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

  # The Kitty shell integration adds an alias for sudo to ensure the
  # TERMINFO environment variable is set correctly. This alias doesn't
  # end with a space. This prevents tab completion to work properly.
  # Therefore this part of the shell integration is disabled. This might
  # not be necessary in a future version of Kitty:
  # https://github.com/kovidgoyal/kitty/commit/492ec3dfbf3be6f27603baabb5c2844f91436e04
  # https://github.com/kovidgoyal/kitty/commit/2aa37de6ffcdd869402283682589b0f405a5f64f
  programs.kitty.shellIntegration.mode = "no-sudo";
}
