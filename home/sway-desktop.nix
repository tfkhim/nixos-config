# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, ... }:
let
  inherit (lib) types mkOption mkIf;

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
    ./modules/sway/sway_config.nix
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
    # rules and systemd services) which can't be done as a user. On the
    # other hand those packages contain also programs that are intended
    # to be used by users. Using those tools from pkgs might lead to
    # duplicated packages from system and user configuration. Therefore
    # this module requires that paths to such tools are passed in
    # through option values.
    programs = {
      swaymsg = mkProgramPath "swaymsg";
      wpctl = mkProgramPath "wpctl";
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

    xdg.portal.restart.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable a race condition fix for xdg-desktop-portal.

        The xdg-desktop-portal D-Bus bindings are started as part of the
        Sway startup process. The Systemd unit providing those bindings
        requires some of the environment variables set by the Sway
        Systemd integration. Setting the environment variables seems to
        run asynchronous to the xdg-desktop-portal unit start. This leads
        to a race condition. If the xdg-desktop-portal unit starts before
        the new environment variables are set it will hang for about 25
        seconds. Waybar will also query the XDG Desktop Portal D-Bus
        interface. This leads to a 25 second delay until Waybar shows
        up.

        This workaround restarts the xdg-desktop-portal service to force
        it to use the environment variables set by Sway.
      '';

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

    systemd.user.services.restart-xdg-desktop-portal = mkIf cfg.xdg.portal.fix.enable {
      Unit = {
        Description =
          "Restarts xdg-desktop-portal to force it to use the new environment variables.";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
        ExecStart = "${pkgs.systemd}/bin/systemctl --user --force restart xdg-desktop-portal";
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
