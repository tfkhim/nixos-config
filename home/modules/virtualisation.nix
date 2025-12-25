# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
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
  inherit (lib)
    types
    mkOption
    mkPackageOption
    mkIf
    ;
  cfg = config.custom.tfkhim.virtualisation;
  dataDir = "${config.xdg.dataHome}/libvirt";
  nixOvmfDir = "${dataDir}/nix-ovmf";
in
{
  options.custom.tfkhim.virtualisation = {
    enable = mkOption {
      description = "Enable and configure virtualisation using libvirt user session";
      type = types.bool;
      default = false;
    };

    ovmf.package = mkPackageOption pkgs [ "OVMF" "fd" ] { };

    swtpm.package = mkPackageOption pkgs "swtpm" { };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libvirt
      cfg.ovmf.package
      # The tools provided by swtpm must be in the
      # PATH for virt-manager to be able to create
      # the required TPM files for a user session.
      cfg.swtpm.package
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

    xdg.dataFile."${nixOvmfDir}/OVMF_CODE.fd".source = "${cfg.ovmf.package}/FV/OVMF_CODE.fd";
    xdg.dataFile."${nixOvmfDir}/OVMF_VARS.fd".source = "${cfg.ovmf.package}/FV/OVMF_VARS.fd";

    xdg.configFile."swtpm_setup.conf".text =
      let
        stateDir = "${dataDir}/swtpm-localca";

        localcaConf = pkgs.writeText "swtpm-localca.conf" ''
          statedir = ${stateDir}
          signingkey = ${stateDir}/signkey.pem
          issuercert = ${stateDir}/issuercert.pem
          certserial = ${stateDir}/certserial
        '';

        localcaOptions = pkgs.writeText "swtpm-localca.options" ''
          --platform-manufacturer NixOS
          --platform-version ${config.home.stateVersion}
          --platform-model Linux
        '';
      in
      ''
        create_certs_tool = ${cfg.swtpm.package}/bin/swtpm_localca
        create_certs_tool_config = ${localcaConf}
        create_certs_tool_options = ${localcaOptions}
        active_pcr_banks = sha256
      '';
  };
}
