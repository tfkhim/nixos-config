# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  osConfig ? null,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    mkIf
    mkDefault
    getExe
    ;

  isNixOS = osConfig != null;

  mkProgramPath =
    program:
    mkOption {
      description = "Path to the ${program} binary.";
      type = with types; nullOr path;
      default = null;
    };
in
{
  options.custom.tfkhim.desktops = {
    # Some tools and services like audio must be installed and configured
    # at system level. They require special system wide setup (like udev
    # rules, systemd services or PAM configuration) which can't be done
    # as a user. On the other hand those packages contain also programs
    # that are intended to be used by users. Using those tools from pkgs
    # might lead to duplicated packages from system and user configuration.
    # Therefore this module requires that paths to such tools are passed
    # in through option values.
    programs = {
      sway = mkProgramPath "sway";
      swaymsg = mkProgramPath "swaymsg";
      wpctl = mkProgramPath "wpctl";
      systemctl = mkProgramPath "systemctl";
      loginctl = mkProgramPath "loginctl";

      # swaylock requires some PAM setup to be able to unlock the user
      # session. Not all combinations of executable and PAM setup seem
      # to work. E.g. swaylock from Nix packages isn't able to unlock
      # with the PAM setup from the Arch Linux swaylock package. This
      # module therefore requires the path to a compatible swaylock
      # program.
      swaylock = mkProgramPath "swaylock";
    };
  };

  config = {
    # In case home-manager runs as a NixOS module we can
    # provide sane defaults for the user space programs.
    custom.tfkhim.desktops.programs = mkIf isNixOS (mkDefault {
      sway = getExe osConfig.programs.sway.package;
      swaymsg = "${osConfig.programs.sway.package}/bin/swaymsg";
      wpctl = "${osConfig.services.pipewire.wireplumber.package}/bin/wpctl";
      systemctl = "${osConfig.systemd.package}/bin/systemctl";
      loginctl = "${osConfig.systemd.package}/bin/loginctl";

      # If the base system is NixOS we can also use swaylock from nixpkgs
      # because the PAM setup from the system should be compatible.
      swaylock = getExe pkgs.swaylock;
    });
  };
}
