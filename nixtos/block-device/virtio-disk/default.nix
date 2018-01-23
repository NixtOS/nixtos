{ pkgs, top }:

{ }:

{
  depends-on = [];

  extra-modules = [ "virtio-pci" "virtio-blk" ];

  build-command = device: "";
}
