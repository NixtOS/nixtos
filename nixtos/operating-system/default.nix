{ pkgs }:
{
  name ? (import ./.. { inherit pkgs; }).version.name,
  kernel ? pkgs.linuxPackages.kernel,
  initrd-modules ? [],
  services ? {},
  hooks ? {
    make-initrd = (import ./.. { inherit pkgs; }).make-initrd;
    solve-services = (import ./.. { inherit pkgs; }).solve-services;
  },
}:

let
  solved-services = hooks.solve-services { inherit kernel services; };

  real-init = pkgs.writeScript "real-init" ''
    #!${pkgs.bash}/bin/bash
    PATH=${pkgs.coreutils}/bin

    # TODO: mount filesystems, etc.

    exec ${solved-services.init-command}
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
