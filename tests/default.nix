let
  pkgs = import <nixpkgs> {};
  nixtos = import ../nixtos { inherit pkgs; };
in
with (import ../nixtos { inherit pkgs; });

assert import ./lib { inherit pkgs nixtos; };

pkgs.writeScript "all-tests" ''
  #!${pkgs.bash}/bin/bash

  # TODO: run VM-based tests here

  echo "Congratulations, all tests passed!"
''
