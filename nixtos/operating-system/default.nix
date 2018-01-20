{ pkgs }:
{
  kernel ? pkgs.linuxPackages.kernel,
}:

let
  # TODO: add nixtos version here
  version = "nixtos-${pkgs.lib.nixpkgsVersion}";

  real-init = pkgs.writeScript "real-init" ''
    #!${pkgs.busybox}/bin/sh

    echo "In real init!"

    while true; do
      sleep 1
    done
  '';

  initrd = import ../make-initrd { inherit pkgs; } { inherit kernel; };
in
pkgs.runCommand version {} ''
  mkdir $out
  ln -s ${kernel}/bzImage $out/kernel
  ln -s ${initrd}/initrd $out/initrd
  ln -s ${real-init} $out/init
''
