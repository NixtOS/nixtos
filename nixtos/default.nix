{ pkgs ? (import <nixpkgs> {}) }:
{
  # TODO: add nixtos version here
  operating-system = pkgs.runCommand "nixtos-${pkgs.lib.nixpkgsVersion}" {} ''
      mkdir $out
  '';
}
