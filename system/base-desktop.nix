# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ pkgs, ... }:

{
  imports = [
    ./single-user.nix
    ./modules/keyboard-remapping.nix
    ./modules/virtualisation.nix
  ];

  # This is needed by the pinentry gnome3 flavor. We enable it
  # in the desktop base file because it may be required by
  # different environments.
  # See:
  # * https://nix-community.github.io/home-manager/options.xhtml#opt-services.gpg-agent.pinentryFlavor
  services.dbus.packages = [ pkgs.gcr ];
}
