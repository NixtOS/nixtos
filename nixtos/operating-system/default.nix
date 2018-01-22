{ pkgs }:
{
  name ? (import ./.. { inherit pkgs; }).version.name,
  kernel ? pkgs.linuxPackages.kernel,
  initrd-modules ? [],
  init ? (import ./.. { inherit pkgs; }).init.runit,
  hooks ? {
    make-initrd = (import ./.. { inherit pkgs; }).make-initrd;
  },
}:

assert pkgs.lib.elem "init" init.types;

let
  real-init = pkgs.writeScript "real-init" ''
    #!${pkgs.bash}/bin/bash
    PATH=${pkgs.coreutils}/bin

    # TODO: mount filesystems, etc.

    exec ${init.command}
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
