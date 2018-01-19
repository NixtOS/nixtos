{ pkgs ? (import <nixpkgs> {}) }:
{
  operating-system = import ./operating-system { inherit pkgs; };
}
