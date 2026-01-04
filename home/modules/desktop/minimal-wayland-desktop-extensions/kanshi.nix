# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, ... }:

{
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
  };

  # Add the kanshi package to be able to easily use
  # kanshictl for reloading the configuration and
  # switching to a different profile.
  home.packages = [ config.services.kanshi.package ];
}
