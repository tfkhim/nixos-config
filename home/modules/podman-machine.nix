# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2024 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, ... }:
let
  inherit (lib)
    types
    optional
    mkOption
    mkEnableOption
    mkPackageOption
    mkIf;

  cfg = config.services.podman-machine;

  podmanPackage = cfg.package;
  podmanExe = lib.getExe podmanPackage;

  wrappedDocker =
    let
      systemctlExe = config.systemd.user.systemctlPath;

      dockerPackage = cfg.docker-wrapper.package;

      wrapper = pkgs.writeShellScriptBin "docker" ''
        SOCKET_FILE="$(${podmanExe} machine inspect ${cfg.name} --format {{.ConnectionInfo.PodmanSocket.Path}})"

        if [[ ! -S "$SOCKET_FILE" ]]; then
          ${systemctlExe} --user start start-podman-machine.service

          until [[ -S "$SOCKET_FILE" ]]; do
            sleep "0.5"
          done
        fi

        export DOCKER_HOST="unix://$SOCKET_FILE"
        ${dockerPackage}/bin/docker "$@"
      '';
    in
    pkgs.symlinkJoin {
      inherit (dockerPackage) name version meta;

      paths = [
        wrapper
        dockerPackage
      ];
    };
in
{
  options.services.podman-machine = {
    enable = mkEnableOption "podman-machine";

    package = mkPackageOption pkgs "podman" { };

    docker-wrapper = {
      enable = mkEnableOption "docker-wrapper";

      package = mkPackageOption pkgs "docker-client" { };
    };

    name = mkOption {
      description = ''
        The name of the podman machine.
      '';
      type = types.str;
      default = "nix-home-manager-default";
    };

    cpus = mkOption {
      description = ''
        The number of CPUs given to the VM.
      '';
      type = types.int;
      default = 2;
    };

    memory = mkOption {
      description = ''
        The memory in MiB given to the VM.
      '';
      type = types.int;
      default = 2048;
    };

    disk-size = mkOption {
      description = ''
        The disk size in GB used for the VM.
      '';
      type = types.int;
      default = 20;
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      [ podmanPackage ]
      ++ optional cfg.docker-wrapper.enable wrappedDocker;

    systemd.user.services.init-podman-machine = {
      Unit = {
        Description = "Initialize a podman machine";
        Documentation = "https://docs.podman.io/en/latest/markdown/podman-machine-init.1.html";
        PartOf = [ "default.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "init-podman-machine" ''
          if ! ${podmanExe} machine inspect ${toString cfg.name} 1>/dev/null 2>/dev/null; then
            ${podmanExe} machine init \
              ${toString cfg.name} \
              --cpus ${toString cfg.cpus} \
              --memory ${toString cfg.memory} \
              --disk-size ${toString cfg.disk-size} \
              --volume "" \
              --rootful
          fi
        '';
      };

      # This explicit dependency ensures the script runs
      # during login. So hopefully the machine is already
      # initialized when docker CLI commands are issued.
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.start-podman-machine = {
      Unit = {
        Description = "Start the podman machine";
        Documentation = "https://docs.podman.io/en/latest/markdown/podman-machine-start.1.html";
        Requires = [ "init-podman-machine.service" ];
        After = [ "init-podman-machine.service" ];
      };

      Service = {
        ExitType = "cgroup";
        ExecStart = "${podmanExe} machine start ${cfg.name}";
        ExecStop = "${podmanExe} machine stop ${cfg.name}";
      };
    };
  };
}

