# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    enableCompletion = true;

    shellAliases = {
      "ls" = "ls --color=auto";
      "ll" = "ls -l --color=auto";
      "lla" = "ls -l --all --color=auto";

      # Git
      # ---

      "gst" = "git status";
      "gl" = "git log";
      "gd" = "git diff";
      "gdc" = "git diff --cached";
      "gau" = "git add --update && git status";
      "gc" = "git commit";
      "gca" = "git commit --amend";
      "gpp" = "git pull --prune";
      "gri" = "git rebase --interactive --autosquash";
    };
  };

  programs.zsh.oh-my-zsh = {
    enable = true;

    plugins = [
      "sudo"

      # gitfast also fixes a strange bug. When completing git log --show<TAB>
      # a hyphen is added. But the cursor is placed before the hyphen. This
      # makes it hard to continue typing. The different completion from
      # gitfast doesn't seem to have this problem.
      "gitfast"
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
