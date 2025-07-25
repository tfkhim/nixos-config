# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  description = "A flake containing NixOS modules I use to build my systems";

  inputs = {
    # This flake doesn't use a nixpkgs-* channel here because it isn't
    # as thoroughly tested as the nixos-* variant. See:
    # https://discourse.nixos.org/t/differences-between-nix-channels/13998
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # This flake doesn't follow nixpkgs by intention. It should
    # be built with the same Rust toolchain version that was also
    # used for building and testing by the upstream project.
    sway-workspace-extras = {
      url = "github:tfkhim/sway-workspace-extras";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      nixos-generators,
      ...
    }@inputs:
    let
      provideFlakeInputsToSystemConfig = rootModule: {
        # The _modules.args option can't be used to add modules
        # from flakes to the imports. Therefore we import the
        # required modules in this wrapper.
        imports = [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          rootModule
        ];

        _module.args.inputs = inputs;
      };

      provideFlakeInputsToHomeManager = rootModule: {
        # This imports follow the same reasoning as in
        # provideFlakeInputsToSystemConfig above.
        imports = [
          sops-nix.homeManagerModules.sops
          rootModule
        ];

        _module.args.inputs = inputs;
      };
    in
    {
      nixosModules = {
        default = self.nixosModules.single-user;
        single-user = provideFlakeInputsToSystemConfig ./system/single-user.nix;
        sway-desktop = provideFlakeInputsToSystemConfig ./system/sway-desktop.nix;
        hyprland-desktop = provideFlakeInputsToSystemConfig ./system/hyprland-desktop.nix;
      };

      homeManagerModules = {
        default = self.homeManagerModules.cli-user;
        cli-user = provideFlakeInputsToHomeManager ./home/cli-user.nix;
        sway-desktop = provideFlakeInputsToHomeManager ./home/sway-desktop.nix;
        hyprland-desktop = provideFlakeInputsToHomeManager ./home/hyprland-desktop.nix;
      };

      packages.x86_64-linux.default = self.packages.x86_64-linux.vm;

      packages.x86_64-linux.vm = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "vm";
        modules = [
          self.nixosModules.sway-desktop
          (
            {
              config,
              pkgs,
              lib,
              ...
            }:
            let
              opensshEnabled = config.services.openssh.enable;
            in
            {
              system.stateVersion = config.system.nixos.release;

              networking.hostName = "test";
              time.timeZone = "Europe/Berlin";
              i18n.defaultLocale = "de_DE.UTF-8";
              console.keyMap = "de-latin1-nodeadkeys";

              users.users.nixos.password = "nixos";

              home-manager.users.nixos.imports = [
                self.homeManagerModules.sway-desktop
                {
                  home.stateVersion = config.system.stateVersion;
                }
              ];

              # For running Sway in a QEMU VM the Arch Linux Wiki recommends to use
              # the QXL virtualized graphics card:
              # https://wiki.archlinux.org/title/sway#Virtualization
              # The screen resolution isn't automatically scaled. Full HD seems to
              # be a good default that should work on most systems well.
              virtualisation.qemu.options = [ "-device qxl-vga,xres=1920,yres=1080" ];

              # The Arch Linux Wiki suggests using the qxl and bochs_drm kernel
              # modules:
              # https://wiki.archlinux.org/title/QEMU#qxl
              boot.kernelModules = [
                "qxl"
                "bochs_drm"
              ];

              virtualisation.forwardPorts = [
                (lib.mkIf opensshEnabled {
                  from = "host";
                  proto = "tcp";
                  host.port = 2222;
                  guest.port = 22;
                })
              ];
            }
          )
        ];
      };

      formatter.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.treefmt.withConfig {
          runtimeInputs = with pkgs; [
            nixfmt-rfc-style
            stylua
          ];

          settings.formatter = {
            nixfmt = {
              command = "nixfmt";
              includes = [ "*.nix" ];
            };

            stylua = {
              command = "stylua";
              options = [
                "--indent-type"
                "Spaces"
              ];
              includes = [ "*.lua" ];
            };
          };
        };
    };
}
