# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  # This service automatically mounts removable media. It
  # requires the udisks2 system service which is enabled in
  # the base-desktop.nix system module.
  services.udiskie.enable = true;
}
