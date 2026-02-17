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

  getHostFilePath = relativePath: "${cfg.stateDir}/shares/config/${relativePath}";
  getSandboxFilePath = relativePath: "/persistent/shared-config/${relativePath}";

  keyType = "ed25519";
  privateAccessKeyFile = "dev_sandbox_${keyType}";
  publicAccessKeyFile = "${privateAccessKeyFile}.pub";
  authorizedKeysFile = "${cfg.user}_authorized_keys";
  privateHostKeyFile = "ssh_host_${keyType}_key";
  publicHostKeyFile = "${privateHostKeyFile}.pub";
in
{
  config = mkIf cfg.enable {
    custom.tfkhim.development-sandbox.shareSetupScripts = ''
      if [ ! -f "${cfg.stateDir}/${privateAccessKeyFile}" ]; then
          ssh-keygen -t ${keyType} -N "" -f "${cfg.stateDir}/${privateAccessKeyFile}"
          chown ${accessUser}:${accessUserGroup} "${cfg.stateDir}/${privateAccessKeyFile}"

          mv "${cfg.stateDir}/${publicAccessKeyFile}" "${getHostFilePath authorizedKeysFile}"
          # Those permissions are important. If the the file or any of its parent
          # directories is writeable by a non-root user the SSH daemon will reject it.
          chown root:root "${getHostFilePath authorizedKeysFile}"
          chmod u=rw,g=r,o=r "${getHostFilePath authorizedKeysFile}"
      fi

      if [ ! -f "${getHostFilePath privateHostKeyFile}" ]; then
          ssh-keygen -t ${keyType} -N "" -f "${getHostFilePath privateHostKeyFile}"
          chown root:root "${getHostFilePath privateHostKeyFile}"
          chown root:root "${getHostFilePath publicHostKeyFile}"
      fi
    '';

    microvm.vms."${cfg.vmName}".config = {
      services.sshd.enable = true;

      services.openssh.hostKeys = [
        {
          path = getSandboxFilePath privateHostKeyFile;
          type = keyType;
        }
      ];

      environment.etc."ssh/authorized_keys.d/${cfg.user}".source = getSandboxFilePath authorizedKeysFile;
    };

    programs.ssh.extraConfig =
      let
        coreutils = pkgs.coreutils-full;

        knownHostsCommand = pkgs.writeShellScript "devsb-known-hosts-command" ''
          echo ${cfg.network.sandbox.ipv4} $(${coreutils}/bin/cut -d ' ' -f 1,2 ${getHostFilePath publicHostKeyFile})
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
