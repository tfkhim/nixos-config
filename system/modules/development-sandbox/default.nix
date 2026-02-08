# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    types
    mkEnableOption
    mkOption
    mkIf
    mkMerge
    ;

  cfg = config.custom.tfkhim.development-sandbox;
in
{
  imports = [
    ./network.nix
    ./share-setup.nix
    ./ssh-access.nix
  ];

  options.custom.tfkhim.development-sandbox = {
    enable = mkEnableOption "development-sandbox";

    vmName = mkOption {
      description = "The name of the sandbox VM";
      default = "development-sandbox";
      type = types.str;
    };

    user = mkOption {
      description = "The name of the main user in the sandbox";
      readOnly = true;
      default = "dev";
      type = types.str;
    };

    stateDir = mkOption {
      description = "The path where VM files are located";
      readOnly = true;
      default = "${config.microvm.stateDir}/${cfg.vmName}";
      type = types.path;
    };

    vcpu = mkOption {
      description = "Number of virtual CPU cores";
      default = 8;
      type = types.ints.positive;
    };

    mem = mkOption {
      description = "Amount of RAM in megabytes";
      default = 8192;
      type = types.ints.positive;
    };

    varSize = mkOption {
      description = "Size of the /var volume";
      default = 8192;
      type = types.ints.positive;
    };

    homeSize = mkOption {
      description = "Size of the /home volume";
      default = 8192;
      type = types.ints.positive;
    };

    systemConfig = mkOption {
      description = "Configuration for the NixOS sandbox";
      type = types.deferredModule;
      default = { };
    };

    userConfig = mkOption {
      description = "Home Manager configuration for the sandbox user";
      type = types.deferredModule;
      default = { };
    };

    shareSetupScripts = mkOption {
      description = "A set of shell script fragments that are executed to populate the shared folders";
      type = types.lines;
      default = "";
    };

    network = {
      interface = mkOption {
        description = "The name for the TAP network interface";
        type = types.str;
        default = "devsb1";
      };

      mac = mkOption {
        description = ''
          The MAC address of the TAP interface. Locally administered
          MAC addresses have one of 2/6/A/E in the second nibble.
        '';
        type = types.str;
        default = "02:00:00:00:00:01";
      };

      host.ipv4 = mkOption {
        description = "The IPv4 address of the host side of the interface";
        type = types.str;
        default = "192.168.117.0";
      };

      host.ipv6 = mkOption {
        description = "The IPv6 address of the host side of the interface";
        type = types.str;
        default = "fec0::";
      };

      sandbox.ipv4 = mkOption {
        description = "The IPv4 of the sandbox";
        type = types.str;
        default = "192.168.117.1";
      };

      sandbox.ipv6 = mkOption {
        description = "The IPv6 of the sandbox";
        type = types.str;
        default = "fec0::1";
      };
    };
  };

  config = mkIf cfg.enable {
    microvm.host.enable = true;

    microvm.vms."${cfg.vmName}" = {
      pkgs = null;
      autostart = false;

      specialArgs = {
        inherit inputs;
        hostConfig = config;
      };

      config = mkMerge [
        cfg.systemConfig
        ./vm
      ];
    };
  };
}
