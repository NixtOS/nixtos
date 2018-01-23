{ pkgs }:

{
  virtio-disk = import ./virtio-disk { inherit pkgs; };
}
