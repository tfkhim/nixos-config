# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  home = {
    # Declare which Home Manager release the configuration is
    # compatible with. This avoids accidental introduction of
    # backwards incompatible changes.
    stateVersion = "23.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

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
