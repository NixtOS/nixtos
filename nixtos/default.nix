{ pkgs ? (import <nixpkgs> {}) }:
{
  build-vm = import ./build-vm { inherit pkgs; };
  make-initrd = import ./make-initrd { inherit pkgs; };
  operating-system = import ./operating-system { inherit pkgs; };
  version = import ./version { inherit pkgs; };
}
