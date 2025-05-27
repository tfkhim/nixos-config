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

  networking.networkmanager.enable = true;

  # This is needed by the pinentry gnome3 package. We enable it
  # in the desktop base file because it may be required by
  # different environments.
  # See:
  # https://nix-community.github.io/home-manager/options.xhtml#opt-services.gpg-agent.pinentryPackage
  services.dbus.packages = [ pkgs.gcr ];

  # This service allows other tools running as a non-privileged
  # user to mount and manipulate devices. This is a requirement
  # for the udiskie service in the base-desktop.nix home manager
  # module.
  services.udisks2.enable = true;

  # The following is required by the Home Manager xdg.portal
  # option to ensure the portal files get linked.
  # See:
  #   https://github.com/nix-community/home-manager/blob/master/modules/misc/xdg-portal.nix#L26
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
}
