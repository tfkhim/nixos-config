# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2025 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, lib, ... }:

{
  programs.starship = {
    enable = true;

    # The default integration enables starship also for /dev/tty* devices.
    # Those can not display most of the characters used by the starship
    # theme. Therefore this configuration uses its own version of the
    # shell initialization.
    enableZshIntegration = false;

    settings = {
      format = "$status|( $cmd_duration|)( $username(@$hostname) |) $directory(| $git_branch$git_commit$git_state$git_metrics$git_status)$character";

      right_format = lib.concatStrings [
        "$jobs"
        "$aws"
        "$java"
        "$nix_shell"
        "$nodejs"
        "$python"
        "$rust"
      ];

      add_newline = false;

      username.format = "[$user]($style)";
      hostname.format = "[$hostname]($style)";

      directory = {
        fish_style_pwd_dir_length = 2;
        style = "bold bright-blue";
      };

      status = {
        disabled = false;
        format = "[$symbol]($style) ";
        symbol = "✘ $status";
        success_symbol = "✔";
        success_style = "bold green";
      };

      git_branch = {
        format = "[$symbol $branch(:$remote_branch)]($style) ";
        symbol = "󰘬";
      };

      nix_shell = {
        format = " [\\[$symbol$state( \($name\))\\]]($style)";
        symbol = " ";
      };

      aws.format = " [\\[$symbol( $profile)( \\($region\\))( \\[$duration\\])\\]]($style)";
      java.format = " [\\[$symbol$version\\]]($style)";
      nodejs.format = " [\\[$symbol$version\\]]($style)";
      python.format = " [\\[$symbol$pyenv_prefix$version( \\($virtualenv\\))\\]]($style)";
      rust.format = " [\\[$symbol($version)\\]]($style)";
    };
  };

  programs.zsh.initContent =
    let
      starshipExe = lib.getExe config.programs.starship.package;
    in
    ''
      if [[ $TERM != "dumb" && ! "$(tty)" =~ "/dev/tty[1-9]" ]]; then
        eval "$(${starshipExe} init zsh)"
      fi
    '';
}
