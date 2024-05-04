# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, inputs, ... }:
let
  inherit (lib) mkIf mkMerge getExe;

  modifier = "Mod4";
  left = "h";
  right = "l";
  up = "k";
  down = "j";

  switchTo = mode: "mode \"${mode}\"";
  switchToDefaultMode = switchTo "default";

  kittyEnabled = config.programs.kitty.enable;
  kitty = getExe config.programs.kitty.package;
  wofi = getExe pkgs.wofi;
  brightnessctl = getExe pkgs.brightnessctl;
  playerctl = getExe pkgs.playerctl;

  workspaceExtrasPkg = inputs.sway-workspace-extras.packages.${pkgs.system}.default;
  sway-workspace-extras = getExe workspaceExtrasPkg;

  nwgBar = "${config.programs.nwg-bar.package}/bin/nwg-bar";
  nwgBarEnabled = config.programs.nwg-bar.enable;

  swaylock = config.desktops.programs.swaylock;
  swaylockEnabled = swaylock != null;

  wpctl = config.desktops.programs.wpctl;
  wpctlEnabled = wpctl != null;

  cursorTheme = config.home.pointerCursor.name;
  cursorThemeEnabled = cursorTheme != null;

  screenshotOfRegion = getExe (
    let
      grim = getExe pkgs.grim;
      slurp = getExe pkgs.slurp;
      swappy = getExe pkgs.swappy;
    in
    pkgs.writeShellApplication {
      name = "screenshot-of-region";

      # wl-copy is required by swappy to copy the
      # image to the clipboard.
      runtimeInputs = [ pkgs.wl-clipboard ];

      text = ''
        ${grim} -g "$(${slurp})" - | ${swappy} -f -
      '';
    }
  );
in
{
  wayland.windowManager.sway.config = {
    inherit modifier left right up down;

    terminal = mkIf kittyEnabled kitty;

    fonts = {
      names = with config.desktops.fonts; [
        sanSerif.name
        symbols.name
      ];
      style = "Bold";
      size = 10.0;
    };

    keybindings = mkMerge [
      {
        #
        # General
        #

        "--inhibited ${modifier}+Escape" = "shortcuts_inhibitor disable";
        "--inhibited ${modifier}+Shift+Escape" = "shortcuts_inhibitor enable";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+Shift+c" = "reload";

        #
        # Backlight
        #

        "XF86MonBrightnessDown" = "exec ${brightnessctl} set 5%-";
        "XF86MonBrightnessUp" = "exec ${brightnessctl} set 5%+";

        #
        # Multimedia
        #

        "XF86AudioPlay" = "exec ${playerctl} play-pause";
        "XF86AudioNext" = "exec ${playerctl} next";
        "XF86AudioPrev" = "exec ${playerctl} previous";

        #
        # Program shortcuts
        #

        "${modifier}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";

        "${modifier}+o" = "exec swaymsg exec -- ${wofi} --show=drun";
        "${modifier}+Shift+P" = "exec ${screenshotOfRegion}";

        #
        # Movement
        #

        # Move your focus around
        "${modifier}+${left}" = "focus left";
        "${modifier}+${down}" = "focus down";
        "${modifier}+${up}" = "focus up";
        "${modifier}+${right}" = "focus right";
        "${modifier}+Prior" = "focus parent";
        "${modifier}+Next" = "focus child";
        "${modifier}+u" = "focus mode_toggle";

        # Move focus to workspace
        "${modifier}+n" = "exec ${sway-workspace-extras} prev";
        "${modifier}+m" = "exec ${sway-workspace-extras} next";

        # Move focus to output
        "${modifier}+alt+n" = "focus output left";
        "${modifier}+alt+m" = "focus output right";

        # Move the focused window with the same, but add Shift
        "${modifier}+Shift+${left}" = "move left";
        "${modifier}+Shift+${down}" = "move down";
        "${modifier}+Shift+${up}" = "move up";
        "${modifier}+Shift+${right}" = "move right";

        # Move focused container to workspace
        "${modifier}+Shift+n" = "exec ${sway-workspace-extras} move-prev";
        "${modifier}+Shift+m" = "exec ${sway-workspace-extras} move-next";

        # Move container to output
        "${modifier}+alt+shift+n" = "move container to output left; focus output left";
        "${modifier}+alt+shift+m" = "move container to output right; focus output right";

        # Scratchpad
        "${modifier}+Shift+i" = "move scratchpad";
        "${modifier}+i" = "scratchpad show";

        #
        # Layout
        #

        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+Escape" = "split none";
        "${modifier}+Shift+o" = "fullscreen";
        "${modifier}+Shift+u" = "floating toggle";

        #
        # Modes
        #

        "${modifier}+Period" = switchTo "resize";
        "${modifier}+Comma" = switchTo "workspace";
      }
      (mkIf swaylockEnabled {
        "Ctrl+Alt+l" = "exec ${swaylock}";
      })
      (mkIf nwgBarEnabled {
        "Ctrl+Alt+Delete" = "exec ${nwgBar}";
      })
      (mkIf wpctlEnabled {
        "XF86AudioRaiseVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "Ctrl+less" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      })
    ];

    modes = {
      resize = {
        "${left}" = "resize shrink width 10px";
        "${down}" = "resize grow height 10px";
        "${up}" = "resize shrink height 10px";
        "${right}" = "resize grow width 10px";

        # Return to default mode
        "Return" = "${switchToDefaultMode}";
        "Escape" = "${switchToDefaultMode}";
      };

      workspace = {
        "s" = "exec ${sway-workspace-extras} shift; ${switchToDefaultMode}";

        # Return to default mode
        "Return" = "${switchToDefaultMode}";
        "Escape" = "${switchToDefaultMode}";
      };
    };

    input = {
      "type:touchpad" = {
        dwt = "enabled";
        tap = "enabled";
        middle_emulation = "enabled";
      };
      "type:keyboard" = {
        xkb_model = "pc101";
        xkb_layout = "de";
      };
    };

    seat = {
      "*" = mkIf cursorThemeEnabled {
        xcursor_theme = cursorTheme;
      };
    };

    output = {
      "*" = {
        bg = "${config.desktops.background} fill";
      };
    };

    window = {
      titlebar = false;
      border = 2;

      commands = [
        # Video playback
        # ==============
        #
        # While watching a video there is no interaction with the system.
        # But one doesn't want the screen to get locked while watching a
        # video. Right now there is no protocol to tell if an application
        # currently plays a video. But normally an application is in
        # fullscreen mode during playback. Therefore the following two
        # rules disable the screen lock for some application if.
        {
          command = "inhibit_idle fullscreen";
          criteria = {
            class = "^firefox$";
          };
        }
        {
          command = "inhibit_idle fullscreen";
          criteria = {
            app_id = "^firefox$";
          };
        }
      ];
    };

    floating = {
      titlebar = false;
      border = 2;
    };

    focus = {
      wrapping = "no";
    };

    gaps = {
      smartBorders = "on";
    };

    colors.focused = {
      background = "#222222";
      border = "#acac53";
      childBorder = "#acac53";
      indicator = "#acac53";
      text = "#ffffff";
    };

    bars = [ ];
  };

  wayland.windowManager.sway.extraConfig = ''
    titlebar_border_thickness 2
  '';
}
