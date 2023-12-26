# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ options, config, pkgs, lib, ... }:
let
  mainUserName = config.users.mainUser;
  cfg = config.users.users.${mainUserName};
  sudoEnabled = config.security.sudo.enable;
  networkmanagerEnabled = config.networking.networkmanager.enable;
in
{
  options.users.mainUser = with lib; mkOption {
    type = types.str;
    default = "nixos";
  };

  config = {
    programs.zsh.enable = true;

    users.users.${mainUserName} = {
      isNormalUser = true;
      home = "/home/${cfg.name}";
      shell = pkgs.zsh;

      extraGroups = with lib; [ ]
        ++ optional sudoEnabled "wheel"
        ++ optional networkmanagerEnabled "networkmanager";
    };

    home-manager.users.${mainUserName}.home = {
      username = cfg.name;
      homeDirectory = cfg.home;
    };
  };
}
