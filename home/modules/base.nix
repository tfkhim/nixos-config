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
}
