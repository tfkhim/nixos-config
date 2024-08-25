# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, osConfig ? null, pkgs, lib, ... }:
let
  inherit (lib) types mkOption mkIf mkDefault getExe;

  cfg = config.desktops;

  isNixOS = osConfig != null;

  mkFontOption = { fontType, defaultName, defaultPackage }: mkOption {
    type = types.submodule {
      options = {
        name = mkOption {
          description = "Name of the ${fontType} font to use.";
          type = types.str;
        };
        package = mkOption {
          description = "Package of the ${fontType} font to use.";
          type = types.package;
        };
      };
    };
    default = {
      name = defaultName;
      package = defaultPackage;
    };
  };

  mkProgramPath = program: mkOption {
    description = "Path to the ${program} binary.";
    type = with types; nullOr path;
    default = null;
  };
in
{
  imports = [
    ./cli-user.nix
    ./modules/virtualisation.nix
    ./modules/podman-machine.nix
  ];

  options.desktops = {
    background = mkOption {
      description = "Image used as the desktop background.";
      type = types.path;
      default = "${pkgs.nixos-artwork.wallpapers.stripes-logo.src}";
    };

    fonts = {
      monospace = mkFontOption {
        fontType = "monospace";
        defaultName = "Hack Nerd Font";
        defaultPackage = pkgs.nerdfonts.override { fonts = [ "Hack" ]; };
      };

      sanSerif = mkFontOption {
        fontType = "san-serif";
        defaultName = "Cantarell";
        defaultPackage = pkgs.cantarell-fonts;
      };

      symbols = mkFontOption {
        fontType = "symbols";
        defaultName = "Symbols Nerd Font";
        defaultPackage = pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; };
      };

      extraPackages = mkOption {
        description = "Additional font packages to install.";
        type = with types; listOf package;
        default = [ pkgs.liberation_ttf ];
      };
    };

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
    home.packages = with pkgs;[
      xdg-utils
    ]
    ++ (with cfg.fonts;[
      monospace.package
      sanSerif.package
      symbols.package
    ])
    ++ cfg.fonts.extraPackages;

    fonts.fontconfig.enable = true;

    # In case home-manager runs as a NixOS module we can
    # provide sane defaults for the user space programs.
    desktops.programs = mkIf isNixOS (mkDefault {
      sway = getExe osConfig.programs.sway.package;
      swaymsg = "${osConfig.programs.sway.package}/bin/swaymsg";
      wpctl = "${osConfig.services.pipewire.wireplumber.package}/bin/wpctl";
      systemctl = "${osConfig.systemd.package}/bin/systemctl";
      loginctl = "${osConfig.systemd.package}/bin/loginctl";

      # If the base system is NixOS we can also use swaylock from nixpkgs
      # because the PAM setup from the system should be compatible.
      swaylock = getExe pkgs.swaylock;
    });

    # This service automatically mounts removable media. It
    # requires the udisks2 system service which is enabled in
    # the base-desktop.nix system module.
    services.udiskie.enable = true;

    programs.direnv = {
      enable = true;

      # The 'use flake' implementation in the direnv standard
      # library already offers good flake support. But nix-direnv
      # still has one big advantage. It makes the inputs of the
      # flake a garbage collection root. Without that feature one
      # has to download the tarballs of the inputs after each
      # garbage collection run. See:
      # https://github.com/nix-community/nix-direnv#flakes-support
      # https://github.com/nix-community/nix-direnv/blob/master/direnvrc#L282
      nix-direnv.enable = true;
    };
  };
}
