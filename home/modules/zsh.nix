# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, lib, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      "ls" = "ls --color=auto";
      "ll" = "ls -l --color=auto";
      "lla" = "ls -l --all --color=auto";

      # Git
      # ---

      "gst" = "git status";
      "gs" = "git show";
      "gl" = "git log";
      "gd" = "git diff";
      "gdc" = "git diff --cached";
      "gau" = "git add --update";
      "gc" = "git commit";
      "gca" = "git commit --amend";
      "gpp" = "git pull --prune";
      "gri" = "git rebase --interactive --autosquash";
    };

    initContent =
      let
        completion = lib.mkOrder 550 ''
          zstyle ':completion:*' completer _complete
          zstyle ':completion:*' menu select
          zstyle ':completion:*' accept-exact-dirs true
          zstyle ':completion:*' special-dirs true
          zstyle ':completion:*' matcher-list "" 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}'
        '';

        historyPrefixCompletion = ''
          autoload -Uz history-search-end
          zle -N history-beginning-search-backward-end history-search-end
          zle -N history-beginning-search-forward-end history-search-end
          bindkey "$terminfo[kcuu1]" history-beginning-search-backward-end
          bindkey "$terminfo[kcud1]" history-beginning-search-forward-end
        '';
      in
      lib.mkMerge [
        completion
        historyPrefixCompletion
      ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
