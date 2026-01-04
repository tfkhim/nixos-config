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
  inherit (lib) types mkOption;

  cfg = config.custom.tfkhim.desktops.fonts;

  mkFontOption =
    {
      fontType,
      defaultName,
      defaultPackage,
    }:
    mkOption {
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
  options.custom.tfkhim.desktops.fonts = {
    monospace = mkFontOption {
      fontType = "monospace";
      defaultName = "Hack Nerd Font";
      defaultPackage = pkgs.nerd-fonts.hack;
    };

    sanSerif = mkFontOption {
      fontType = "san-serif";
      defaultName = "Cantarell";
      defaultPackage = pkgs.cantarell-fonts;
    };

    symbols = mkFontOption {
      fontType = "symbols";
      defaultName = "Symbols Nerd Font";
      defaultPackage = pkgs.nerd-fonts.symbols-only;
    };

    emoji = mkFontOption {
      fontType = "Emoji";
      defaultName = "Noto Color Emoji";
      defaultPackage = pkgs.noto-fonts-color-emoji;
    };

    extraPackages = mkOption {
      description = "Additional font packages to install.";
      type = with types; listOf package;
      default = [ pkgs.liberation_ttf ];
    };
  };

  config = {
    home.packages =
      (with cfg; [
        monospace.package
        sanSerif.package
        symbols.package
        emoji.package
      ])
      ++ cfg.extraPackages;

    fonts.fontconfig.enable = true;
  };
}
