# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  programs.git = {
    enable = true;

    extraConfig = {
      merge = {
        conflictstyle = "diff3";
      };
      pull = {
        ff = "only";
      };
    };

    delta = {
      enable = true;
      options = {
        side-by-side = true;
        hyperlinks = true;
      };
    };
  };
}
