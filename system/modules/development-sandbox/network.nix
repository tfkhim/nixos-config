# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.custom.tfkhim.development-sandbox;
in
{
  config = mkIf cfg.enable {
    networking.networkmanager.unmanaged = [ cfg.network.interface ];

    networking.useNetworkd = true;

    systemd.network = {
      wait-online.enable = false;

      networks."30-development-sandbox" = {
        matchConfig.Name = cfg.network.interface;

        address = [
          "${cfg.network.host.ipv4}/32"
          "${cfg.network.host.ipv6}/128"
        ];

        routes = [
          {
            Destination = "${cfg.network.sandbox.ipv4}/32";
          }
          {
            Destination = "${cfg.network.sandbox.ipv6}/128";
          }
        ];

        networkConfig = {
          IPv4Forwarding = true;
          IPv6Forwarding = true;
        };
      };
    };

    networking.nat = {
      enable = true;
      enableIPv6 = true;

      internalIPs = [ cfg.network.sandbox.ipv4 ];
      internalIPv6s = [ cfg.network.sandbox.ipv6 ];
    };
  };
}
