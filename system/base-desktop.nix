# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  imports = [
    ./single-user.nix
    ./modules/keyboard-remapping.nix
    ./modules/virtualisation.nix
  ];
}
