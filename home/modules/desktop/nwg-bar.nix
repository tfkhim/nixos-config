# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, ... }:
let
  inherit (lib) types mkOption mkPackageOption mkIf;

  cfg = config.programs.nwg-bar;

  systemctl = config.desktops.programs.systemctl;
  loginctl = config.desktops.programs.loginctl;
in
{
  options.programs.nwg-bar = {
    enable = mkOption {
      description = "Enable nwg-bar";
      type = types.bool;
      default = true;
    };

    package = mkPackageOption pkgs "nwg-bar" { };

    actions =
      let
        mkActionOption = { name, defaultEnable, defaultIcon }: {
          enable = mkOption {
            description = "Enable the ${name} action.";
            type = types.bool;
            default = defaultEnable;
          };
          icon = mkOption {
            description = ''
              The icon for the ${name} action. This can be:
                * a path to a *.png or *.svg file
                * a system icon name like 'system-log-out'
              See https://github.com/nwg-piotr/nwg-bar#templates for reference.
            '';
            type = with types; oneOf [ str path ];

            default = "${cfg.package}/share/nwg-bar/images/${defaultIcon}.svg";
          };
        };
      in
      {
        logout = mkActionOption {
          name = "logout";
          defaultEnable = true;
          defaultIcon = "system-log-out";
        };
        reboot = mkActionOption {
          name = "reboot";
          defaultEnable = true;
          defaultIcon = "system-reboot";
        };
        hibernate = mkActionOption {
          name = "hibernate";
          defaultEnable = false;
          defaultIcon = "system-hibernate";
        };
        shutdown = mkActionOption {
          name = "shutdown";
          defaultEnable = true;
          defaultIcon = "system-shutdown";
        };
      };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = systemctl != null && loginctl != null;
        message = "The options 'desktops.programs.systemctl' and 'desktops.programs.loginctl' must be specified.";
      }
    ];

    home.packages = [ cfg.package ];

    xdg.configFile."nwg-bar/bar.json".text =
      let
        enableLogout = cfg.actions.logout.enable;
        enableReboot = cfg.actions.reboot.enable;
        enableHibernate = cfg.actions.hibernate.enable;
        enableShutdown = cfg.actions.shutdown.enable;

        logoutScript = pkgs.writers.writeBash "logout" ''
          ${loginctl} terminate-user $USER
        '';

        logout = {
          label = "Logout";
          exec = logoutScript;
          icon = cfg.actions.logout.icon;
        };
        reboot = {
          label = "Reboot";
          exec = "${systemctl} reboot";
          icon = cfg.actions.reboot.icon;
        };
        hibernate = {
          label = "Hibernate";
          exec = "${systemctl} hibernate";
          icon = cfg.actions.hibernate.icon;
        };
        shutdown = {
          label = "Shutdown";
          exec = "${systemctl} poweroff";
          icon = cfg.actions.shutdown.icon;
        };
      in
      builtins.toJSON ([ ]
        ++ (lib.optional enableLogout logout)
        ++ (lib.optional enableReboot reboot)
        ++ (lib.optional enableHibernate hibernate)
        ++ (lib.optional enableShutdown shutdown)
      );

    xdg.configFile."nwg-bar/style.css".source = ./nwg-bar-style.css;
  };
}
