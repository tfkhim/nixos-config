# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, ... }:
let
  # The module uses the rainbow configuration as the baseline and
  # changes only the necessary settings. This dramatically reduces
  # the amount of required configuration.
  p10kSettings = {
    #
    # Prompt element setup
    # ====================
    #

    # Some reasons for this setup:
    #
    # - Having the status and execution time of the last command
    #   as the first elements in the prompt feels more natural.
    #   You first read the information for the last call and then
    #   only context information for the next call comes afterwards.
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = [
      "status"
      "command_execution_time"
      "dir"
      "vcs"
    ];

    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS = [
      "background_jobs"
      "nix_shell"
      "virtualenv"
      "pyenv"
      "node_version"
      "rust_version"
      "java_version"
      "kubecontext"
      "terraform"
      "aws"
      "aws_eb_env"
      "ranger"
      "nnn"
      "xplr"
      "vim_shell"
      "midnight_commander"
      "vi_mode"
    ];

    #
    # general styling
    # ---------------
    #

    # This settings disable the powerline style and
    # replace it by a more lean styling. There is
    # no background color for the individual elements,
    # but angle separators between them and at the
    # end of the left prompt and start of the right
    # prompt.
    POWERLEVEL9K_BACKGROUND = "";
    POWERLEVEL9K_FOREGROUND = 7;

    POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR = "%244F";
    POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR = "%244F";
    POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL = "%244F";
    POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL = "%244F";

    #
    # vcs status
    # ----------
    #
    # Do not show the Git or GitHub icon at the start but
    # show the branch icon if currently on a branch.
    POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION = "";
    POWERLEVEL9K_VCS_BRANCH_ICON = "󰘬 ";

    #
    # rust_version
    # ------------
    #
    # Use a more "rusty" color instead of the default cyan.
    # The default icon is also very small. Using a string as
    # identifier is much more readable.

    POWERLEVEL9K_RUST_VERSION_FOREGROUND = 136;
    POWERLEVEL9K_RUST_VERSION_VISUAL_IDENTIFIER_EXPANSION = "[rust]";

    #
    # node_version
    # ------------
    #
    # The default icon isn't related to Node.JS at all. Sadly
    # there is no Node.JS symbol that is big enough to recognize
    # it. Therefore a string identifier is used here, too.

    POWERLEVEL9K_NODE_VERSION_VISUAL_IDENTIFIER_EXPANSION = "[node]";
  };

  package = pkgs.zsh-powerlevel10k;
in
{
  programs.zsh = {
    # This ZSH plugin is only sourced for non-tty terminals. On a tty the
    # theme is most likely broken due to incompatible fonts. 
    initExtra = ''
      if [[ $TERM != "dumb" && ! "$(tty)" =~ "/dev/tty[1-9]" ]]; then
        source ${package}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${package}/share/zsh-powerlevel10k/config/p10k-classic.zsh
        ${config.lib.zsh.defineAll p10kSettings}
      fi
    '';
  };
}
