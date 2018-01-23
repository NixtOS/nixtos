{ pkgs }:

{ }:

{
  extra-initrd-modules = [ "virtio-pci" "virtio-blk" ];

  build-command = "";
}
