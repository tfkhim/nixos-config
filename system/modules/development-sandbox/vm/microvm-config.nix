# This file is part of https://github.com/tfkhim/nixos-config
#
# Copyright (c) 2026 Thomas Himmelstoss
#
# This software is subject to the MIT license. You should have
# received a copy of the license along with this program.

{ hostConfig, ... }:
let
  cfg = hostConfig.custom.tfkhim.development-sandbox;
in
{
  microvm = {
    # It seems like cloud-hypervisor has some performance issues during startup
    # and shutdown. There is also an issue describing this:
    #  https://github.com/microvm-nix/microvm.nix/issues/366
    # Therefore, this module uses qemu until there is some time evaluate different
    # options.
    # hypervisor = "cloud-hypervisor";
    hypervisor = "qemu";

    vsock.cid = 3;

    vcpu = cfg.vcpu;
    mem = cfg.mem;
    socket = "control.socket";

    # Home Manager needs a writeable Nix store
    writableStoreOverlay = "/nix/.rw-store";

    # The dedupe option doesn't lead to a big size reduction
    # and takes too much time during the build. According to the
    # erofs documentation LZ4 has the best runtime performance:
    # https://erofs.docs.kernel.org/en/latest/faq.html
    storeDiskErofsFlags = [
      "-zlz4"
      "-Efragments,ztailpacking"
    ];

    volumes = [
      {
        mountPoint = "/";
        image = "root_volume.img";
        size = cfg.diskSize;
      }
    ];

    interfaces = [
      {
        type = "tap";
        id = cfg.network.interface;
        mac = cfg.network.mac;
      }
    ];
  };
}
