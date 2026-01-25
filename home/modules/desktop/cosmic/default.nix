# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  config,
  pkgs,
  lib,
  ...
}:
let
  configDir = "${config.xdg.configHome}/cosmic";
in
{
  home.activation.copyCosmicConfiguration = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.coreutils}/bin/cp --force --recursive --no-preserve=mode ${./config_files}/* "${configDir}"
  '';
}
