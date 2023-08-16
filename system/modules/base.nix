# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ pkgs, inputs, ... }:

{
  # Declare which NixOS release the configuration is
  # compatible with. This avoids accidental introduction
  # of backwards incompatible changes.
  system.stateVersion = "23.11";

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];

    # Ensure the nix commands (e.g. nix run) use the same
    # nixpkgs version as this flake. This reduces the amount
    # of nixpkgs tarball downloads and should also improve
    # reuse of the existing entries in the store. In general
    # this should make those commands more efficient.
    registry.nixpkgs.flake = inputs.nixpkgs;
  };

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "de_DE.UTF-8";

  console.keyMap = "de-latin1";

  users.mutableUsers = false;

  environment.systemPackages = with pkgs; [
    git
    dig
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
