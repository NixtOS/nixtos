{ pkgs, top }:

{
  virtio-disk = import ./virtio-disk { inherit pkgs top; };
}
