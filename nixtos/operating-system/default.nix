{ pkgs }:
{
  name ? "nixtos-${pkgs.lib.nixpkgsVersion}", # TODO: add nixtos version here
  kernel ? pkgs.linuxPackages.kernel,
  initrd-modules ? [],
  hooks ? {
    make-initrd = (import ./.. { inherit pkgs; }).make-initrd;
  },
}:

let
  real-init = pkgs.writeScript "real-init" ''
    #!${pkgs.bash}/bin/bash
    PATH=${pkgs.coreutils}/bin

    echo "In real init!"

    while true; do
      sleep 1
    done
  '';

  initrd = hooks.make-initrd {
    inherit kernel;
    modules = initrd-modules;
  };
in
pkgs.runCommand name {} ''
  mkdir $out
  ln -s ${kernel}/bzImage $out/kernel
  ln -s ${initrd}/initrd $out/initrd
  ln -s ${real-init} $out/init
''
