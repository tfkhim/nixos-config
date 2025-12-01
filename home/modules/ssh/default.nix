# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ pkgs, ... }:
let
  # Many remote systems don't have terminfo files for Kitty,
  # Alacritty or other more uncommon terminals. This leads to
  # different problems in interactive session. To solve such
  # issues one should copy the terminfo file to the remote
  # host:
  # https://wiki.archlinux.org/title/OpenSSH#%22Terminal_unknown%22_or_%22Error_opening_terminal%22_error_message
  copyTerminfo = pkgs.stdenv.mkDerivation rec {
    name = "copy-terminfo";

    buildInputs = [ pkgs.python3 ];

    src = ./copy_terminfo.py;
    dontUnpack = true;

    installPhase = "install -Dm755 $src $out/bin/copy-terminfo";
  };
in
{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };

  };

  home.packages = [ copyTerminfo ];

  services.ssh-agent.enable = true;
}
