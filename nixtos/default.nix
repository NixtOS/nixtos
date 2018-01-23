{ pkgs }:
{
  block-device = import ./block-device { inherit pkgs; };
  build-vm = import ./build-vm { inherit pkgs; };
  files = import ./files { inherit pkgs; };
  make-initrd = import ./make-initrd { inherit pkgs; };
  init = import ./init { inherit pkgs; };
  operating-system = import ./operating-system { inherit pkgs; };
  solve-services = import ./solve-services { inherit pkgs; };
  version = import ./version { inherit pkgs; };
}
