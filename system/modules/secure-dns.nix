# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, ... }:
let
  # resolved listens by default at 127.0.0.53. Therefore using 127.0.0.1 for
  # dnscrypt-proxy2 is save.
  dnsProxyAddress = "127.0.0.1";
  stateDirectory = "dnscrypt-proxy";
in
{
  assertions = [
    {
      assertion = config.systemd.services.dnscrypt-proxy2.serviceConfig.StateDirectory == stateDirectory;
      message = "StateDirectory of dnscrypt-proxy2 service was changed";
    }
  ];

  # dnscrypt-proxy2 supports many protocols for secure DNS queries. Most notably
  # it supports DNSCrypt and DoH. Both use port 443 which makes it impossible to
  # block those protocols without blocking any HTTPS traffic as well. This is a
  # very useful property because some open Wifi's block many ports including
  # 53 (DNS) and 853 (DoT).
  #
  # This service also supports caching of DNS queries which is turned on by
  # default:
  # https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Performance#dns-cache
  services.dnscrypt-proxy2 = {
    enable = true;
    upstreamDefaults = false;

    settings = {
      listen_addresses = [ "${dnsProxyAddress}:53" ];

      server_names = [
        "quad9-dnscrypt-ip4-filter-pri"
        "quad9-dnscrypt-ip4-filter-alt"
        "quad9-dnscrypt-ip4-filter-alt2"
        "quad9-dnscrypt-ip6-filter-pri"
        "quad9-dnscrypt-ip6-filter-alt"
        "quad9-dnscrypt-ip6-filter-alt2"
        "quad9-doh-ip4-port443-filter-pri"
        "quad9-doh-ip4-port443-filter-alt"
        "quad9-doh-ip4-port443-filter-alt2"
        "quad9-doh-ip6-port443-filter-pri"
        "quad9-doh-ip6-port443-filter-alt"
        "quad9-doh-ip6-port443-filter-alt2"
      ];

      sources.quad9Resolvers = {
        urls = [
          "https://quad9.net/dnscrypt/quad9-resolvers.md"
          "https://raw.githubusercontent.com/Quad9DNS/dnscrypt-settings/main/dnscrypt/quad9-resolvers.md"
        ];
        minisign_key = "RWTp2E4t64BrL651lEiDLNon+DqzPG4jhZ97pfdNkcq1VDdocLKvl5FW";
        cache_file = "/var/lib/${stateDirectory}/quad9-resolvers.md";
        refresh_delay = 72;
        prefix = "quad9-";
      };
    };
  };

  # dnscrypt-proxy2 has many security features but it lacks split DNS support.
  # On the other hand a split DNS setup with systemd-resolved and NetworkManager
  # is very easy because they integrate very well with each other. Therefore this
  # setup uses systemd-resolved for the split DNS part. But it forwards all DNS
  # queries that are not specific to an interface to the dnscrypt-proxy2 service.

  # This value will be used for the systemd-resolved DNS configuration value. This
  # should be the dnscrypt-proxy2 resolver.
  networking.nameservers = [ dnsProxyAddress ];


  # systemd-resolved also supports caching of requests. But there is no need to
  # disable it explicitly because it is disabled if the DNS server is host
  # local like in this setup:
  # https://man.archlinux.org/man/resolved.conf.5.en#OPTIONS
  services.resolved = {
    enable = true;
    # This ensures all queries are forwarded to dnscrypt-proxy2. If a link has a
    # more specific query (e.g. my.network) the queries (e.g. host.my.network)
    # for this domain will be sent to the DNS server of the link instead.
    domains = [ "~." ];

    # systemd-resolved has a compiled in list of fallback DNS resolvers. Using an
    # empty list for this setting will result in resolved using this list. But
    # having fallback resolvers may hide problems with the setup. Therefore the
    # fallbacks are as well set to the dnscrypt-proxy2 service.
    fallbackDns = [ dnsProxyAddress ];
  };
}
