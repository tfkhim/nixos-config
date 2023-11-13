# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      runAsRoot = false;

      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };

      swtpm.enable = true;
    };
  };
}
