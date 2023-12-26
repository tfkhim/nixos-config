# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, ... }:
let
  inherit (lib) types mkOption mkIf;

  # The full variant of the UEFI firmware is used here
  # because it contains secure boot support which is
  # required for Windows 11.
  ovmf = pkgs.OVMFFull.fd;

  nixOvmfDir = "${config.xdg.dataHome}/libvirt/nix-ovmf";
in
{
  options.virtualisation = {
    enable = mkOption {
      description = "Enable and configure virtualisation using libvirt user session";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.virtualisation.enable {
    home.packages = with pkgs; [
      libvirt
      ovmf
      # The tools provided by swtpm must be in the
      # PATH for virt-manager to be able to create
      # the required TPM files for a user session.
      swtpm
      virt-manager
      # The Remote-Viewer program provided by the
      # virt-viewer package can share folders using
      # the SPICE WebDAV server. This isn't possible
      # with virt-manager.
      virt-viewer
    ];

    # The goal here is to provide libvirt stable paths to the firmware
    # files. Therefore, the following code uses an indirection through
    # symbolic links in ~/.local/share/libvirt/nix-ovmf instead of
    # directly passing the store paths into the qemu.conf file. This is
    # similar to the approach in the NixOS system libvirt configuration
    # that creates symbolic links in /run/libvirt/nix-ovmf.
    xdg.configFile."libvirt/qemu.conf".text = ''
      nvram = ["${nixOvmfDir}/OVMF_CODE.fd:${nixOvmfDir}/OVMF_VARS.fd"]
    '';

    xdg.dataFile."${nixOvmfDir}/OVMF_CODE.fd".source = "${ovmf}/FV/OVMF_CODE.fd";
    xdg.dataFile."${nixOvmfDir}/OVMF_VARS.fd".source = "${ovmf}/FV/OVMF_VARS.fd";
  };
}
