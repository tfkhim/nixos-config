# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ options, config, pkgs, lib, ... }:
let
  cfg = config.users.mainUser;
  enableHomeManager = builtins.length cfg.homeManagerModules > 0;
  sudoEnabled = config.security.sudo.enable;
in
{
  options = with lib; {
    users.mainUser = {
      name = mkOption {
        type = with types; passwdEntry str;
        default = "nixos";
      };

      description = mkOption {
        type = with types; passwdEntry str;
        default = "";
      };

      password = mkOption {
        type = with types; nullOr str;
        default = null;
      };

      passwordFile = mkOption {
        type = with types; nullOr str;
        default = null;
      };

      homeManagerModules = mkOption {
        type = with types;
          let
            module = oneOf [ path attrs (functionTo attrs) ];
          in
          listOf module;
        default = [ ];
      };
    };
  };

  config = {
    programs.zsh.enable = true;

    users.users.mainUser = {
      inherit (cfg) name description password passwordFile;
      isNormalUser = true;
      home = "/home/${cfg.name}";
      shell = pkgs.zsh;

      extraGroups = with lib; [ ]
        ++ optional sudoEnabled "wheel";
    };

    home-manager.users.mainUser = lib.mkIf enableHomeManager {
      imports = cfg.homeManagerModules;

      home = with config.users.users.mainUser; {
        username = name;
        homeDirectory = home;
      };
    };
  };
}
