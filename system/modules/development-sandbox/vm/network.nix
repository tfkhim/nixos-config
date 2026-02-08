# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ hostConfig, ... }:
let
  cfg = hostConfig.custom.tfkhim.development-sandbox;
in
{
  networking.useNetworkd = true;

  systemd.network.networks."10-eth" = {
    matchConfig.MACAddress = cfg.network.mac;
    address = [
      "${cfg.network.sandbox.ipv4}/32"
      "${cfg.network.sandbox.ipv6}/128"
    ];

    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = cfg.network.host.ipv4;
        GatewayOnLink = true;
      }
      {
        Destination = "::/0";
        Gateway = cfg.network.host.ipv6;
        GatewayOnLink = true;
      }
    ];

    # The single-user.nix system module contains a DNS setup.
    # Therefore, this network configuration doesn't need
    # to specify the DNS servers, in contrast to
    # https://microvm-nix.github.io/microvm.nix/routed-network.html#virtual-machine-configuration
  };
}
