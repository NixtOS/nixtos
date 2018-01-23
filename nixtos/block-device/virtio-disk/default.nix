{ pkgs, top }:

{ }:

{ device }:

{
  extra-modules = [ "virtio-pci" "virtio-blk" ];

  build-command = "";
}
