# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ pkgs, ... }:

{
  imports = [
    ./cli-user.nix
    ./modules/virtualisation.nix
  ];

  # This service automatically mounts removable media. It
  # requires the udisks2 system service which is enabled in
  # the base-desktop.nix system module.
  services.udiskie.enable = true;

  programs.direnv = {
    enable = true;

    # The 'use flake' implementation in the direnv standard
    # library already offers good flake support. But nix-direnv
    # still has one big advantage. It makes the inputs of the
    # flake a garbage collection root. Without that feature one
    # has to download the tarballs of the inputs after each
    # garbage collection run. See:
    # https://github.com/nix-community/nix-direnv#flakes-support
    # https://github.com/nix-community/nix-direnv/blob/master/direnvrc#L282
    nix-direnv.enable = true;
  };
}
