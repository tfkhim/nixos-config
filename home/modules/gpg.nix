# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ pkgs, config, lib, ... }:

{
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
    mutableKeys = lib.mkDefault false;
    mutableTrust = lib.mkDefault false;
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = lib.mkDefault pkgs.pinentry-tty;
  };
}
