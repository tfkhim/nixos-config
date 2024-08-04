# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ config, lib, ... }:
let
  inherit (lib) mkOption types mkIf;

  cfg = config.keyboard.remapping;
  enableRemapping = with cfg; capslockMeta || emulate102nd;

  # A multi use button should behave as follows:
  # * On a quick tap it activates the tap action.
  # * Holding down the key and pressing another button should
  #   perform the other button press within the holding layer.
  # * Outwaiting some timeout should afterwards not trigger
  #   the tap action if the button is released without a
  #   second button press.
  # This is how Kmonad's tap-hold-next behaves. The overlay action
  # of keyd doesn't satisfy the third requirement. The timeout action
  # of keyd doesn't satisfy the second requirement. But the following
  # combination of both actions gives the desired behavior.
  mkMultiUseButton = tapAction: layer:
    "timeout(overload(${layer}, ${tapAction}), 200, layer(${layer}))";
in
{
  options = {
    keyboard.remapping = {
      exclude = mkOption {
        description = ''
          A list of keyboards to which the remapping should not be applied.
          This is useful to ignore keyboards that may already have a
          programmable firmware like QMK.
        '';
        type = types.listOf types.str;
        default = [ ];
      };
      capslockMeta = mkOption {
        description = ''
          Many window manager key bindings use the meta modifier because
          this modifier isn't used much by applications. This avoids
          potential collisions between application and window manager key
          bindings. On ANSI and ISO keyboards the meta button is not that
          easy to reach. With that in mind it makes sense to remap the
          capslock button to the meta modifier. In addition to that this
          option makes the capslock button behave like escape if it is
          only tapped. Escape is another important button that is hard to
          reach on common physical keyboard layouts.
        '';
        type = types.bool;
        default = false;
      };

      emulate102nd = mkOption {
        description = ''
          The ANSI physical layout doesn't provide the 102nd (e.g. < > |)
          button which can be found on ISO physical layouts. This makes it
          hard to use a key map which requires this button (e.g. de) on
          ANSI physical layouts. Therefore this option emulates this button
          by overloading the left shift key:
           * A tap of the left shift button will result in a
             102nd button tap
           * Holding the left shift button still behaves like
             holding down the shift modifier
        '';
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf enableRemapping {
    services.keyd.enable = true;

    services.keyd.keyboards.default = {
      ids = [ "*" ] ++ (map (id: "-${id}") cfg.exclude);

      settings = {
        main = {
          # It would also be possible to remap capslock to meta by
          # setting input.xkb_options to "caps:super" in the Sway
          # configuration. But this approach has one drawback: For some
          # applications like VM viewers or remote desktop viewers the
          # raw capslock press and release is sent to the VM or remote
          # desktop. This leads to capslock being turned on for the VM
          # or remote desktop if one uses capslock on the host when such
          # an application has focus. This happens a lot if meta is part
          # of the window or workspace navigation key bindings.
          #
          # Performing the remapping with keyd avoids this, because Sway
          # always sees only the result of the remapping.
          capslock = mkIf cfg.capslockMeta (mkMultiUseButton "esc" "meta");

          leftshift = mkIf cfg.emulate102nd (mkMultiUseButton "102nd" "shift");
        };
      };
    };
  };
}
