# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, ... }:

{
  # We also need to run the Nix garbage collector as the
  # Home Manager user. Because the generations in the
  # ~/.local/state/nix/profiles directory aren't deleted
  # by the system level garbage collector.
  nix.gc = {
    automatic = true;
    # Sadly daily is not a supported value right now.
    frequency = "weekly";
    options = "--delete-older-than 10d";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  sops.age = {
    keyFile = lib.mkDefault "${config.home.homeDirectory}/.data/sops_user_key.txt";
    generateKey = lib.mkDefault false;
  };

  systemd.user =
    let
      unitName = "maintain-age-key-ownership-and-permissions";
      keyFile = config.sops.age.keyFile;
      ageKeyDefined = keyFile != null;
    in
    lib.mkIf ageKeyDefined {
      services.${unitName} = {
        Unit.Description = "Ensures the private age user key is only readable by the user";

        # This explicit dependency ensures the script runs
        # at least once during login. So even if the file
        # initially has the wrong permissions and is never
        # changed it will get the right permissions.
        Install.WantedBy = [ "default.target" ];

        Service = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript unitName ''
            if [[ -f "${keyFile}" ]]; then
              ${pkgs.coreutils}/bin/chmod 0600 "${keyFile}"
            fi
          '';
        };
      };

      paths.${unitName} = {
        Unit.Description = "Monitor ${keyFile} permissions";

        Install.WantedBy = [ "default.target" ];

        Path.PathChanged = keyFile;
      };
    };
}
