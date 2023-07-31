# NixOS Configuration

This Nix flake contains a set of NixOS modules. I use those modules to build
my different systems.

# Usage

One must include this flake as an input of a downstream flake and use the
modules there to build up a `nixosConfigurations` attribute set. You need to
specify some additional information like `networking.hostName`,
`users.mainUser.name`, `users.mainUser.password` or
`users.mainUser.passwordFile`, ...

# Development

You can start a QEMU VM by running the default application of the flake

    nix run

The username and password is `nixos`.
