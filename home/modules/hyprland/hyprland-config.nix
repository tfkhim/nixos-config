# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2024 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkMerge getExe;

  modifier = "SUPER";
  left = "h";
  right = "l";
  up = "k";
  down = "j";

  kitty = getExe config.programs.kitty.package;
  wofi = getExe pkgs.wofi;
  brightnessctl = getExe pkgs.brightnessctl;
  playerctl = getExe pkgs.playerctl;

  nwgBar = "${config.programs.nwg-bar.package}/bin/nwg-bar";
  nwgBarEnabled = config.programs.nwg-bar.enable;

  wpctl = config.desktops.programs.wpctl;
  wpctlEnabled = wpctl != null;

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
  wayland.windowManager.hyprland.settings = {
    "$mod" = modifier;

    bind = mkMerge [
      [
        "${modifier}_SHIFT, q, killactive"

        #
        # Program shortcuts
        #

        "${modifier}, Return, exec, ${kitty}"
        "${modifier}, o, exec, ${wofi} --show=drun"
        "${modifier}_SHIFT, p, exec, ${screenshotOfRegion}"
        "CTRL_ALT, l, exec, ${config.desktops.programs.loginctl} lock-session"

        # Move your focus around
        "${modifier}, ${left}, movefocus, l"
        "${modifier}, ${right}, movefocus, r"
        "${modifier}, ${down}, movefocus, d"
        "${modifier}, ${up}, movefocus, u"

        # Move focus to workspace
        "${modifier}, n, workspace, r-1"
        "${modifier}, m, workspace, r+1"

        # Move the focused window
        "${modifier}_SHIFT, ${left}, movewindow, l"
        "${modifier}_SHIFT, ${right}, movewindow, r"
        "${modifier}_SHIFT, ${down}, movewindow, d"
        "${modifier}_SHIFT, ${up}, movewindow, u"

        # Move focused container to workspace
        "${modifier}_SHIFT, n, movetoworkspace, r-1"
        "${modifier}_SHIFT, m, movetoworkspace, r+1"

        # Layout
        "${modifier}_SHIFT, o, fullscreen, 0"
        "${modifier}_SHIFT, u, togglefloating"

        # Special workspace
        "${modifier}_SHIFT, i, movetoworkspace, special"
        "${modifier}, i, togglespecialworkspace"

        #
        # Backlight
        #

        ", XF86MonBrightnessDown, exec, ${brightnessctl} set 5%-"
        ", XF86MonBrightnessUp, exec, ${brightnessctl} set 5%+"

        #
        # Multimedia
        #

        ", XF86AudioPlay, exec, ${playerctl} play-pause"
        ", XF86AudioNext, exec, ${playerctl} next"
        ", XF86AudioPrev, exec, ${playerctl} previous"
      ]
      (mkIf nwgBarEnabled [
        "CTRL_ALT, Delete, exec, ${nwgBar}"
      ])
      (mkIf wpctlEnabled [
        ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", Ctrl+less, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ])
    ];

    bindm = [
      "${modifier},mouse:272,movewindow"
    ];

    input = {
      kb_model = "pc101";
      kb_layout = "de";
      follow_mouse = 2;

      touchpad = {
        disable_while_typing = true;
        tap-to-click = true;
      };
    };

    general = {
      gaps_out = 0;
      gaps_in = 2;
      border_size = 1;
      "col.active_border" = "rgb(3584e4)";
      no_focus_fallback = true;
      resize_on_border = true;
    };

    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };

    animations = {
      enabled = false;
      first_launch_animation = false;
    };

    # The next options are recommended to save on
    # battery by disabling resource hungry effects
    # and reduce the amount of sent frames.
    # See:
    #   https://wiki.hyprland.org/Configuring/Performance
    decoration = {
      drop_shadow = false;

      blur = {
        enabled = false;
      };
    };

    misc.vrr = 1;
  };
}
