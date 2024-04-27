# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, ... }:
let
  cfg = config.desktops.sway;

  extraConfig3And4 = {
    gtk-application-prefer-dark-theme = true;
  };
in
{
  gtk = {
    enable = true;

    font.name = cfg.fonts.sanSerif.name;

    theme = {
      name = "Adwaita-dark";
      # gnome-themes-extra contains the Adwaita theme for
      # GTK 2 and 3 which is required by the Qt integration.
      package = pkgs.gnome.gnome-themes-extra;
    };

    iconTheme = {
      name = "breeze-dark";
      package = pkgs.libsForQt5.breeze-icons;
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    gtk3.extraConfig = extraConfig3And4;
    gtk4.extraConfig = extraConfig3And4;
  };

  qt = {
    enable = true;
    style.name = "gtk2";
    platformTheme.name = "gtk";
  };

  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.libsForQt5.breeze-qt5;
    size = 24;

    gtk.enable = true;
    x11.enable = true;
  };

  programs.nwg-bar.actions =
    let
      actionIcons = "${pkgs.libsForQt5.breeze-icons}/share/icons/breeze-dark/actions/32";
    in
    {
      logout.icon = "${actionIcons}/system-log-out.svg";
      reboot.icon = "${actionIcons}/system-reboot.svg";
      hibernate.icon = "${actionIcons}/system-hibernate.svg";
      shutdown.icon = "${actionIcons}/system-shutdown.svg";
    };
}
