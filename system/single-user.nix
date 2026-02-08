# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2023 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{
  imports = [
    ./modules/base.nix
    ./modules/development-sandbox
    ./modules/main-user.nix
    ./modules/secure-dns.nix
    ./modules/sshd.nix
  ];
}
