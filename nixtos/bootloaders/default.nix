{ pkgs, top }:

loaders:

# TODO(medium): handle multiple bootloaders
assert builtins.length loaders == 1;

pkgs.writeScript "install-bootloaders" ''
  #!${pkgs.bash}/bin/bash

  ${pkgs.lib.concatStringsSep "\n" (map toString loaders)}
''
