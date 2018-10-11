let
  pkgs = import <nixpkgs> {};
  nixtos = import ../nixtos { inherit pkgs; };
in
with (import ../nixtos { inherit pkgs; });

let
  lib-tests = import ./lib { inherit pkgs nixtos; };
  run-lib-tests =
    if lib-tests == [] then {}
    else throw ''
      Some library tests failed!

      ${builtins.concatStringsSep "\n" (builtins.map (f:
        " * ${f.name}:\n" +
        "   Expected ${builtins.toJSON f.expected}\n" +
        "   Got      ${builtins.toJSON f.result}\n"
      ) lib-tests)}
    '';
in

builtins.seq
  run-lib-tests
  (pkgs.writeScript "all-tests" ''
    #!${pkgs.bash}/bin/bash

    # TODO(medium): run VM-based tests here

    echo "Congratulations, all tests passed!"
  '')
