# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.custom.tfkhim.latest-pkgs = mkOption {
    description = "A set of Nix packages containing the latest versions.";
    type = types.pkgs;
  };

  config.custom.tfkhim.latest-pkgs = import inputs.nixpkgs-unstable {
    inherit (pkgs)
      config
      overlays
      ;

    system = pkgs.stdenv.hostPlatform.system;
  };
}
