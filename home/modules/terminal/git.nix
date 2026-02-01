# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  programs.git = {
    enable = true;

    settings = {
      merge = {
        conflictstyle = "diff3";
      };
      fetch = {
        prune = true;
      };
      pull = {
        ff = "only";
      };
    };

  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;

    options = {
      side-by-side = true;
      hyperlinks = true;
      # Git sets the LESS environment variable if it is not set
      # to FRX. The F option exits less if the content fits on
      # on screen. This defies the purpos of the paging setting
      # below.
      # See: https://git-scm.com/docs/git-config/2.22.0#Documentation/git-config.txt-corepager
      pager = "less -+FX";
      paging = "always";
    };
  };
}
