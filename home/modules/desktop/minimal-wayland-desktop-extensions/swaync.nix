# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2024 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkPackageOption mkIf;

  cfg = config.custom.tfkhim.services.sway-notification-center;

  systemdTarget = config.custom.tfkhim.desktops.minimal-wayland-desktop-extensions.systemdTarget;
in
{
  options.custom.tfkhim.services.sway-notification-center = {
    enable = mkEnableOption "sway-notification-center";

    package = mkPackageOption pkgs "swaynotificationcenter" { };
  };

  config = mkIf cfg.enable {

    xdg.configFile."swaync/config.json".text = builtins.toJSON {
      hide-on-clear = true;
      hide-on-action = true;
    };

    xdg.configFile."swaync/style.css".source = ./swaync-style.css;

    systemd.user.services.sway-notification-center = {
      Unit = {
        Description = "A notification center for Sway and other wlroots based compositors.";
        Documentation = "https://github.com/ErikReider/SwayNotificationCenter";
        PartOf = [ systemdTarget ];
        After = [ systemdTarget ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/swaync";
        ExecReload = "${cfg.package}/bin/swaync-client --reload-config";
      };

      Install = {
        WantedBy = [ systemdTarget ];
      };
    };
  };
}
