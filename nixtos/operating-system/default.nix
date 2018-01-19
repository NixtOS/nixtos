{ pkgs }:
{
  kernel ? pkgs.linuxPackages.kernel,
}:

let
  # TODO: add nixtos version here
  version = "nixtos-${pkgs.lib.nixpkgsVersion}";
in
pkgs.runCommand version {} ''
  mkdir $out
  ln -s ${kernel} $out/kernel
''
