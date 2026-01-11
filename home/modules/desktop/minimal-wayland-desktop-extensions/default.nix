# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, lib, ... }:
let
  inherit (lib) mkOption types removeSuffix;

  cfg = config.custom.tfkhim.desktops.minimal-wayland-desktop-extensions;

  description = "Systemd target to bind services required to extend a minimal Wayland desktops";
in
{
  imports = [
    ./kanshi.nix
    ./mate-polkit-agent.nix
    ./nwg-bar.nix
    ./swaync.nix
    ./waybar.nix
  ];

  options.custom.tfkhim.desktops.minimal-wayland-desktop-extensions = {
    systemdTarget = mkOption {
      readOnly = true;
      inherit description;
      type = types.str;
      default = "minimal-wayland-desktop-extensions.target";
    };
  };

  config = {
    systemd.user.targets.${removeSuffix ".target" cfg.systemdTarget} = {
      Unit = {
        Description = description;
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        After = [
          config.custom.tfkhim.desktops.hyprland.systemdTarget
          config.custom.tfkhim.desktops.sway.systemdTarget
          "graphical-session.target"
        ];
      };

      Install = {
        WantedBy = [
          config.custom.tfkhim.desktops.hyprland.systemdTarget
          config.custom.tfkhim.desktops.sway.systemdTarget
        ];
      };
    };
  };
}
