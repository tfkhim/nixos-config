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
  sshfs = "${pkgs.sshfs}/bin/sshfs";
  scp = "${config.programs.ssh.package}/bin/scp";
  git = "${config.programs.git.package}/bin/git";

  startCommand = "${config.systemd.package}/bin/systemctl start microvm@${cfg.vmName}.service";

  devsb = pkgs.writeShellScriptBin "devsb" ''
    set -euo pipefail

    function hasSandboxRemote() {
      ${git} remotes show | grep -q "${cfg.vmName}" && echo true || echo false
    }

    function getRemoteDir() {
      isGitRepo="$(${git} rev-parse --is-inside-work-tree 2>/dev/null || echo false)"

      if [ "$isGitRepo" = "true" ] && [ hasSandboxRemote = "true" ]; then
        echo $(${git} remote get-url ${cfg.vmName} | sed 's\ssh://[^/]*\\')
      else
        echo "/home/${cfg.user}/$(${realpath} -m --relative-to=$HOME $PWD)"
      fi
    }

    function workspaceInit() {
      workspaceDir="/home/${cfg.user}/$(${realpath} -m --relative-to=$HOME $PWD)"
      workspaceParent=$(${dirname} "$workspaceDir")
      ${ssh} ${cfg.vmName} mkdir -p "$workspaceParent"

      isGitRepo="$(${git} rev-parse --is-inside-work-tree 2>/dev/null || echo false)"

      if [ "$isGitRepo" = "true" ]; then
        branch=$(${git} branch --show-current)

        ${ssh} ${cfg.vmName} git init -b "$branch" "$workspaceDir"
        ${ssh} ${cfg.vmName} /bin/sh "-c 'cd $workspaceDir && git remote add origin /dev/null'"
        ${git} remote remove "${cfg.vmName}" || true
        ${git} remote add "${cfg.vmName}" "ssh://${cfg.vmName}$workspaceDir"
        workspaceReset
      else
        ${scp} -r "$PWD" "${cfg.vmName}:$workspaceDir"
      fi
    }

    function workspacePush() {
      branch=$(${git} branch --show-current)
      ${git} push --force "${cfg.vmName}" "$branch:origin/$branch"
    }

    function workspaceReset() {
      workspacePush

      workspaceDir=$(${git} remote get-url ${cfg.vmName} | sed 's\ssh://[^/]*\\')
      branch=$(${git} branch --show-current)
      ${ssh} ${cfg.vmName} /bin/sh "-c 'cd $workspaceDir && git restore --staged --worktree .; git clean -d --force; git switch $branch; git branch --set-upstream-to=origin/$branch $branch; git reset --hard origin/$branch'"
      ${git} fetch "${cfg.vmName}"
    }

    function workspaceGet() {
      ${git} fetch "${cfg.vmName}"
      branch=$(${git} branch --show-current)
      ${ssh} ${cfg.vmName} "cd $(getRemoteDir) && exec git diff 'origin/$branch'" | ${git} apply --index --allow-empty
    }

    function workspaceGetCommits() {
      ${git} fetch "${cfg.vmName}"
      headBeforeCherryPick=$(${git} rev-parse HEAD)
      branch=$(${git} branch --show-current)
      numCommits="$(${git} rev-list "${cfg.vmName}/origin/$branch..${cfg.vmName}/$branch" | wc --lines)"
      if [ "$numCommits" -gt 0 ]; then
        ${git} cherry-pick --empty=drop "${cfg.vmName}/origin/$branch..${cfg.vmName}/$branch"
        ${git} rebase --exec "${git} commit --amend --no-edit --no-verify --reset-author" $headBeforeCherryPick $branch
      fi
    }

    function workspaceGetSquashed() {
      branch=$(${git} branch --show-current)
      ${git} fetch "${cfg.vmName}"
      ${git} merge --squash --no-commit "${cfg.vmName}/$branch"
    }

    function workspaceMount() {
        mountDir="''${1:-./sandbox}"
        mkdir -p "$mountDir"
        ${sshfs} "${cfg.vmName}:$(getRemoteDir)" "$mountDir"
    }

    case "''${1:-no-args}" in
      enter|no-args)
        exec ${ssh} -t ${cfg.vmName} "cd $(getRemoteDir) 2>/dev/null; exec \$SHELL"
        ;;
      start)
        exec "${config.security.wrapperDir}/sudo" ${startCommand}
        ;;
      ws-init)
        workspaceInit
        ;;
      ws-push)
        workspacePush
        ;;
      ws-reset)
        workspaceReset
        ;;
      ws-get)
        workspaceGet
        ;;
      ws-get-commits)
        workspaceGetCommits
        ;;
      ws-get-squashed)
        workspaceGetSquashed
        ;;
      ws-exec)
        shift
        exec ${ssh} -t ${cfg.vmName} "cd $(getRemoteDir) && exec $@"
        ;;
      ws-mount)
        shift
        workspaceMount "$@"
        ;;
      exec)
        shift
        exec ${ssh} -t ${cfg.vmName} "$@"
        ;;
      *)
        echo "Unknown command: $1"
        exit 1
        ;;
    esac
  '';
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = [ devsb ];

    security.sudo.extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = startCommand;
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
