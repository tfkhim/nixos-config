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

    history.path = "${config.xdg.dataHome}/zsh/zsh_history";

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
          zstyle ':completion:*' matcher-list "" 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}'

          # Complete the . and .. directories with a slash
          zstyle ':completion:*' special-dirs true

          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

          # Use caching so that long running commands are useable
          zstyle ':completion:*' use-cache yes
          zstyle ':completion:*' cache-path "${config.xdg.cacheHome}/zsh"
        '';

        keyBindings = ''
          bindkey -e

          # Delete with backspace
          bindkey -M emacs '^?' backward-delete-char

          # Delete with delete key
          bindkey -M emacs "$terminfo[kdch1]" delete-char

          # Edit the current command line in an editor
          autoload -U edit-command-line
          zle -N edit-command-line
          bindkey '\C-x\C-e' edit-command-line
        '';

        historyPrefixCompletion = ''
          autoload -U up-line-or-beginning-search
          zle -N up-line-or-beginning-search
          bindkey "$terminfo[kcuu1]" up-line-or-beginning-search

          autoload -U down-line-or-beginning-search
          zle -N down-line-or-beginning-search
          bindkey "$terminfo[kcud1]" down-line-or-beginning-search
        '';

        awsProfileSelection = ''
          function asp() {
            export AWS_PROFILE=$1
          }
        '';
      in
      lib.mkMerge [
        completion
        keyBindings
        historyPrefixCompletion
        awsProfileSelection
      ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
