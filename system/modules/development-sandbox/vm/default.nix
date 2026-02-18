# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  hostConfig,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkMerge;
  cfg = hostConfig.custom.tfkhim.development-sandbox;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    ../../base.nix
    ../../main-user.nix
    ../../secure-dns.nix
    ../../sshd.nix
    ./microvm-config.nix
    ./network.nix
  ];

  system.stateVersion = hostConfig.system.stateVersion;

  networking.hostName = cfg.vmName;
  time.timeZone = hostConfig.time.timeZone;
  i18n.defaultLocale = hostConfig.i18n.defaultLocale;
  console.keyMap = hostConfig.console.keyMap;

  custom.tfkhim.mainUser = cfg.user;

  # Getting locked out is not a problem for a sandbox and the
  # dev user shouldn't need root access.
  users.allowNoPasswordLogin = true;
  security.sudo.enable = false;

  # Useful to ensure the required terminfo files are there
  # without needing to copying them manually.
  environment.enableAllTerminfo = true;

  # Avoid long shutdown or reboot times. See:
  # https://mas.to/@zekjur/113109742103219075
  systemd.settings.Manager.DefaultTimeoutStopSec = "3s";

  home-manager.users.${cfg.user} = mkMerge [
    inputs.sops-nix.homeManagerModules.sops
    ../../../../home/cli-user.nix
    cfg.userConfig
    {
      home.stateVersion = hostConfig.system.stateVersion;

      # Required to create Git commits as the sandbox user.
      programs.git.settings.user = {
        email = "${cfg.user}@${cfg.vmName}.local";
        name = cfg.user;
      };
    }
  ];
}
