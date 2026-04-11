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
  inherit (lib) mkIf;

  cfg = config.custom.tfkhim.development-sandbox;

  accessUser = config.custom.tfkhim.mainUser;
  accessUserGroup = config.users.users.${accessUser}.group;

  keyType = "ed25519";
  privateAccessKeyFile = "dev_sandbox_${keyType}";
  publicAccessKeyFile = "${privateAccessKeyFile}.pub";
  authorizedKeysFile = "${cfg.user}_authorized_keys";
  privateHostKeyFile = "ssh_host_${keyType}_key";
  publicHostKeyFile = "${privateHostKeyFile}.pub";

  driveLabel = "ssh-config";
  mountPath = "/ssh_config";
in
{
  config = mkIf cfg.enable {
    systemd.services.development-sandbox-build-ssh-config = {
      serviceConfig.Type = "oneshot";
      unitConfig.ConditionPathExists = cfg.stateDir;
      requiredBy = [ "install-microvm-${cfg.vmName}.service" ];
      after = [ "install-microvm-${cfg.vmName}.service" ];
      before = [ "microvm@${cfg.vmName}.service" ];
      path = [
        pkgs.coreutils
        config.services.openssh.package
        pkgs.erofs-utils
      ];
      script = ''
        if [ ! -f "${cfg.stateDir}/ssh_config.erofs" ] || [ ! -f "${cfg.stateDir}/${privateAccessKeyFile}" ] || [ ! -f "${cfg.stateDir}/${publicHostKeyFile}" ]; then
          tmpDir=$(mktemp -d)
          mkdir -p "$tmpDir/${mountPath}"

          ssh-keygen -t ${keyType} -N "" -f "$tmpDir/${privateAccessKeyFile}"
          mv "$tmpDir/${publicAccessKeyFile}" "$tmpDir/${mountPath}/${authorizedKeysFile}"

          ssh-keygen -t ${keyType} -N "" -f "$tmpDir/${mountPath}/${privateHostKeyFile}"

          # Those permissions are important. If the the file or any of its parent
          # directories is writeable by a non-root user the SSH daemon will reject it.
          chown -R root:root "$tmpDir/${mountPath}"
          chmod u=rw,g=r,o=r "$tmpDir/${mountPath}/${authorizedKeysFile}"

          mkfs.erofs -L ${driveLabel} "${cfg.stateDir}/ssh_config.erofs" "$tmpDir/${mountPath}"

          mv "$tmpDir/${privateAccessKeyFile}" "${cfg.stateDir}/${privateAccessKeyFile}"
          chown ${accessUser}:${accessUserGroup} "${cfg.stateDir}/${privateAccessKeyFile}"

          cp "$tmpDir/${mountPath}/${publicHostKeyFile}" "${cfg.stateDir}/${publicHostKeyFile}"
          chown ${accessUser}:${accessUserGroup} "${cfg.stateDir}/${publicHostKeyFile}"
        fi
      '';
    };

    microvm.vms."${cfg.vmName}".config = {
      microvm.qemu.extraArgs = [
        "-drive"
        "id=${driveLabel},format=raw,read-only=on,file=${cfg.stateDir}/ssh_config.erofs,if=none,aio=io_uring"
        "-device"
        "virtio-blk-device,drive=${driveLabel}"
      ];

      fileSystems.${mountPath} = {
        device = "/dev/disk/by-label/${driveLabel}";
        fsType = "erofs";
        options = [ "x-systemd.after=systemd-modules-load.service" ];
        neededForBoot = true;
        noCheck = true;
      };

      services.sshd.enable = true;

      services.openssh.hostKeys = [
        {
          path = "${mountPath}/${privateHostKeyFile}";
          type = keyType;
        }
      ];

      environment.etc."ssh/authorized_keys.d/${cfg.user}".source = "${mountPath}/${authorizedKeysFile}";
    };

    programs.ssh.extraConfig =
      let
        coreutils = pkgs.coreutils-full;

        knownHostsCommand = pkgs.writeShellScript "devsb-known-hosts-command" ''
          echo ${cfg.network.sandbox.ipv4} $(${coreutils}/bin/cut -d ' ' -f 1,2 ${cfg.stateDir}/${publicHostKeyFile})
        '';
      in
      ''
        Host ${cfg.vmName}
          HostName ${cfg.network.sandbox.ipv4}
          User ${cfg.user}
          IdentitiesOnly yes
          IdentityFile ${cfg.stateDir}/${privateAccessKeyFile}
          KnownHostsCommand=${knownHostsCommand}
      '';
  };
}
