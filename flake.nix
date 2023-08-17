# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  description = "A flake containing NixOS modules I use to build my systems";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-generators, ... }@inputs: {
    nixosModules =
      let
        provideFlakeInputs = rootModule: {
          # The _modules.args option can not be used to add modules
          # from flakes to the imports. Therefore we import the
          # required modules in this wrapper.
          imports = [
            home-manager.nixosModules.home-manager
            rootModule
          ];

          _module.args.inputs = inputs;
        };
      in
      {
        default = self.nixosModules.single-user;
        single-user = provideFlakeInputs ./system/single-user.nix;
      };

    homeManagerModules = {
      default = self.homeManagerModules.cli-user;
      cli-user = ./home/cli-user.nix;
    };

    packages.x86_64-linux.default = self.packages.x86_64-linux.vm;

    packages.x86_64-linux.vm = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "vm";
      modules = [
        self.nixosModules.single-user
        ({ config, lib, ... }:
          let
            opensshEnabled = config.services.openssh.enable;
          in
          {
            networking.hostName = "test";

            users.users.nixos.password = "nixos";

            home-manager.users.nixos.imports = [ self.homeManagerModules.cli-user ];

            # For running Sway in a QEMU VM the Arch Linux Wiki recommends to use
            # the QXL virtualized graphics card:
            # https://wiki.archlinux.org/title/sway#Virtualization
            # The screen resolution isn't automatically scaled. Full HD seems to
            # be a good default that should work on most systems well.
            virtualisation.qemu.options = [ "-device qxl-vga,xres=1920,yres=1080" ];

            # The Arch Linux Wiki suggests using the qxl and bochs_drm kernel
            # modules:
            # https://wiki.archlinux.org/title/QEMU#qxl
            boot.kernelModules = [ "qxl" "bochs_drm" ];

            virtualisation.forwardPorts = [
              (lib.mkIf opensshEnabled { from = "host"; proto = "tcp"; host.port = 2222; guest.port = 22; })
            ];
          })
      ];
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}
