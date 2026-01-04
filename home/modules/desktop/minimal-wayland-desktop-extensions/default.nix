# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  imports = [
    ./kanshi.nix
    ./mate-polkit-agent.nix
    ./nwg-bar.nix
    ./swaync.nix
    ./waybar.nix
  ];
}
