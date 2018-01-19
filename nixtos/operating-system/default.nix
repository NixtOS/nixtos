{ pkgs }:
{ }:

let
  # TODO: add nixtos version here
  version = "nixtos-${pkgs.lib.nixpkgsVersion}";
in
pkgs.runCommand version {} ''
    mkdir $out
''
