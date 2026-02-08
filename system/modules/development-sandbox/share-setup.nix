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
in
{

  config = mkIf cfg.enable {
    systemd.services.prepare-development-sandbox-shares = {
      serviceConfig.Type = "oneshot";
      unitConfig.ConditionPathExists = cfg.stateDir;
      requiredBy = [ "install-microvm-${cfg.vmName}.service" ];
      after = [ "install-microvm-${cfg.vmName}.service" ];
      before = [ "microvm@${cfg.vmName}.service" ];
      path = [
        pkgs.coreutils
        config.services.openssh.package
      ];
      script = ''
        if [ ! -d "${cfg.stateDir}/shares" ]; then
          mkdir -p "${cfg.stateDir}/shares/config"
          chown microvm:kvm "${cfg.stateDir}/shares"


          # Those permissions are important. Some applications,
          # like sshd check that paths from the root dir to
          # some file are only writeable by the root user.
          chown root:root "${cfg.stateDir}/shares/config"
          chmod u=rwx,g=rx,o=rx "${cfg.stateDir}/shares/config"
        fi

        ${cfg.shareSetupScripts}
      '';
    };
  };
}
