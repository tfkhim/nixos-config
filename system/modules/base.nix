# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, inputs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];

    # Ensure the nix commands (e.g. nix run) use the same
    # nixpkgs version as this flake. This reduces the amount
    # of nixpkgs tarball downloads and should also improve
    # reuse of the existing entries in the store. In general
    # this should make those commands more efficient.
    registry.nixpkgs.flake = inputs.nixpkgs;

    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };
  };

  users.mutableUsers = false;

  environment.systemPackages = with pkgs; [
    git
    dig
    usbutils
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  sops.age = {
    keyFile = lib.mkDefault "/sops_host_key.txt";
    generateKey = lib.mkDefault false;
  };

  systemd =
    let
      unitName = "maintain-age-key-ownership-and-permissions";
      keyFile = config.sops.age.keyFile;
      ageKeyDefined = keyFile != null;
    in
    lib.mkIf ageKeyDefined {
      services.${unitName} = {
        description = "Ensures the private age host key is only readable by the root user";

        # This explicit dependency ensures the script runs
        # at least once during boot. So even if the file
        # initially has the wrong permissions and is never
        # changed it will get the right permissions.
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";

        script = ''
          if [[ -f "${keyFile}" ]]; then
            ${pkgs.coreutils}/bin/chown root:root "${keyFile}"
            ${pkgs.coreutils}/bin/chmod 0600 "${keyFile}"
          fi
        '';
      };

      paths.${unitName} = {
        description = "Monitor ${keyFile} ownership and permissions";

        wantedBy = [ "multi-user.target" ];

        pathConfig.PathChanged = keyFile;
      };
    };
}
