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

  coreutils = pkgs.coreutils-full;
  realpath = "${coreutils}/bin/realpath";
  dirname = "${coreutils}/bin/dirname";
  ssh = "${config.programs.ssh.package}/bin/ssh";
  scp = "${config.programs.ssh.package}/bin/scp";
  git = "${config.programs.git.package}/bin/git";

  devsb = pkgs.writeShellScriptBin "devsb" ''
    set -euo pipefail

    function workspaceInit() {
      workspaceDir="/home/${cfg.user}/$(${realpath} -m --relative-to=$HOME $PWD)"
      workspaceParent=$(${dirname} "$workspaceDir")
      ${ssh} ${cfg.vmName} mkdir -p "$workspaceParent"

      isGitRepo="$(${git} rev-parse --is-inside-work-tree 2>/dev/null || echo false)"

      if [ "$isGitRepo" = "true" ]; then
        branch=$(${git} branch --show-current)

        ${ssh} ${cfg.vmName} git init -b "$branch" "$workspaceDir"
        ${ssh} ${cfg.vmName} $SHELL "-c 'cd $workspaceDir && git remote add origin /dev/null'"
        ${git} remote remove "${cfg.vmName}" || true
        ${git} remote add "${cfg.vmName}" "ssh://${cfg.vmName}$workspaceDir"
        workspaceReset
      else
        ${scp} -r "$PWD" "${cfg.vmName}:$workspaceDir"
      fi
    }

    function workspaceReset() {
      workspaceDir=$(${git} remote get-url ${cfg.vmName} | sed 's\ssh://[^/]*\\')
      branch=$(${git} branch --show-current)
      ${git} push --force "${cfg.vmName}" "$branch:origin/$branch"
      ${ssh} ${cfg.vmName} $SHELL "-c 'cd $workspaceDir && git restore --staged --worktree . ; git clean -x; git switch $branch; git reset --hard origin/$branch'"
    }

    case "''${1:-no-args}" in
      enter|no-args)
        exec ${ssh} ${cfg.vmName}
        ;;
      ws-init)
        workspaceInit
        ;;
      ws-reset)
        workspaceReset
        ;;
      exec)
        shift
        exec ${ssh} ${cfg.vmName} "$@"
        ;;
      *)
        exec ${ssh} ${cfg.vmName} "$@"
        ;;
    esac
  '';
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = [ devsb ];
  };
}
