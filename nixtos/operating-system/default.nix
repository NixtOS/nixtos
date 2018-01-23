{ pkgs }:
{
  name ? (import ./.. { inherit pkgs; }).version.name,
  kernel ? pkgs.linuxPackages.kernel,
  initrd-modules ? [],
  block-devices,
  filesystems,
  services ? {},
  hooks ? {
    make-initrd = (import ./.. { inherit pkgs; }).make-initrd;
    solve-services = (import ./.. { inherit pkgs; }).solve-services;
  },
}:

assert !(services ? "kernel");
assert !(services ? "activation-scripts");

let
  solved-services = hooks.solve-services services;

  kernel-extenders = solved-services.extenders-for-assert-type "kernel" "init";
  init-command = assert builtins.length kernel-extenders == 1;
                 (builtins.head kernel-extenders).command;

  activation-extenders =
    solved-services.extenders-for-assert-type "activation-scripts" "script";
  activation-script = builtins.concatStringsSep "\n" (
    map (e: e.script) activation-extenders
  );

  real-init = pkgs.writeScript "real-init" ''
    #!${pkgs.bash}/bin/bash
    PATH=${pkgs.coreutils}/bin

    # TODO: mount filesystems, etc.

    ${activation-script}

    exec ${init-command}
  '';

  initrd = hooks.make-initrd {
    inherit kernel;

    modules = initrd-modules ++
              pkgs.lib.flatten (pkgs.lib.mapAttrsToList (device: device-type:
                (device-type { inherit device; }).extra-modules
              ) block-devices);

    inherit filesystems;
  };
in
pkgs.runCommand name {} ''
  mkdir $out
  ln -s ${kernel}/bzImage $out/kernel
  ln -s ${initrd}/initrd $out/initrd
  ln -s ${real-init} $out/init
''
