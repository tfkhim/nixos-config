# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, ... }:
let
  inherit (lib) types mkOption;

  cfg = config.desktops.sway;

  mkProgramPath = program: mkOption {
    description = "Path to the ${program} binary.";
    type = with types; nullOr path;
    default = null;
  };

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
in
{
  imports = [
    ./cli-user.nix
    ./modules/sway/sway-config.nix
    ./modules/sway/theming.nix
    ./modules/sway/waybar.nix
    ./modules/sway/screenlocking.nix
  ];

  options.desktops.sway = {
    background = mkOption {
      description = "Background image used for sway and swaylock.";
      type = types.path;
      default = "${pkgs.nixos-artwork.wallpapers.stripes-logo.src}";
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
      swaymsg = mkProgramPath "swaymsg";
      wpctl = mkProgramPath "wpctl";

      # swaylock requires some PAM setup to be able to unlock the user
      # session. Not all combinations of executable and PAM setup seem
      # to work. E.g. swaylock from Nix packages isn't able to unlock
      # with the PAM setup from the Arch Linux swaylock package. This
      # module therefore requires the path to a compatible swaylock
      # program.
      swaylock = mkProgramPath "swaylock";
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
  };

  config = {
    home.packages = [
      cfg.fonts.monospace.package
      cfg.fonts.sanSerif.package
      cfg.fonts.symbols.package
    ] ++ cfg.fonts.extraPackages;

    fonts.fontconfig.enable = true;

    programs.kitty = {
      enable = true;
    };

    wayland.windowManager.sway = {
      enable = true;
      package = null;
    };
  };
}
