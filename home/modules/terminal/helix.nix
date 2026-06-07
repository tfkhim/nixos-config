# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  programs.helix = {
    enable = true;

    settings = {
      theme = "adwaita-dark";

      editor = {
        cursorline = true;
        cursor-shape.insert = "bar";
        line-number = "relative";
      };
    };
  };
}
