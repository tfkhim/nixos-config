# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, ... }:

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
  # for the udiskie service in the desktop/base/services.nix
  # home manager module.
  services.udisks2.enable = true;

  # This is a requirement for flatpak. It is normally enabled by
  # desktop eenvironments, anyway.
  xdg.portal.enable = true;

  services.flatpak.enable = true;
  systemd.services.ensure-flathub-repo = {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    path = [ config.services.flatpak.package ];
    script = ''
      flatpak remote-add --if-not-exists flathub ${./flathub.flatpakrepo}
    '';
  };
}
