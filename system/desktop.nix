# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, ... }:
let
  uwsmHyprlandSessionTarget = "wayland-session@hyprland\\x2duwsm.desktop.target";
in
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

  # Provides the org.freedesktop.RealtimeKit1 DBus service to
  # XDG Desktop Portal. Without this journalctl contains some
  # warnings due to the missing interface.
  security.rtkit.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Adding the hyprland-session.target allows the auxiliary
  # services (e.g. hypridle) to depend on the same target
  # no matter which Systemd integration approach was chosen.
  systemd.user.targets.hyprland-session = {
    description = "Hyprland compositor session";
    documentation = [ "man:systemd.special(7)" ];
    wants = [ "graphical-session-pre.target" ];
    wantedBy = [ uwsmHyprlandSessionTarget ];
    bindsTo = [ "graphical-session.target" ];
    after = [
      uwsmHyprlandSessionTarget
      "graphical-session-pre.target"
    ];
  };

  programs.sway = {
    enable = true;
    xwayland.enable = true;

    # This module assumes that other required tools (e.g.
    # swaylock or swayidle) are installed through the home
    # manager configuration. This avoids installing packages
    # that are not used by the users Sway configuration.
    extraPackages = [ ];
  };
}
