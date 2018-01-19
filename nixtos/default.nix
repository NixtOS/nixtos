{ pkgs ? (import <nixpkgs> {}) }:
{
  build-vm = import ./build-vm { inherit pkgs; };
  operating-system = import ./operating-system { inherit pkgs; };
}
