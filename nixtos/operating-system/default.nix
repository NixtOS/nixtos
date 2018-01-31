{ pkgs, top }:
{
  name ? top.version.name,
  kernel ? pkgs.linuxPackages.kernel,
  initrd-modules ? [],
  block-devices,
  filesystems,
  services ? {},
}:

assert !(services ? "kernel");
assert !(services ? "activation-scripts");

let
  solved-services = top.solve-services services;

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
    PATH=${pkgs.coreutils}/bin:${pkgs.utillinux}/bin

    echo "Mounting filesystems"
    mkdir /dev /proc /sys
    mount -t devtmpfs none /dev
    mount -t proc none /proc
    mount -t sysfs none /sys
    ${(top.solve-filesystems filesystems).mount-all "/"}

    # TODO(low): allow configuring what is /bin/sh?
    mkdir -p /bin
    ln -s ${pkgs.bash}/bin/bash /bin/sh

    ${activation-script}

    exec ${init-command}
  '';

  initrd = top.make-initrd {
    inherit kernel;

    modules = pkgs.lib.unique (
      initrd-modules ++
      pkgs.lib.flatten (pkgs.lib.mapAttrsToList (device: device-type:
        device-type.extra-modules
      ) block-devices) ++
      pkgs.lib.flatten (pkgs.lib.mapAttrsToList (fs-name: fs-type:
        fs-type.extra-modules
      ) filesystems)
    );

    inherit block-devices filesystems;
  };
in
pkgs.runCommand name {} ''
  mkdir $out
  ln -s ${kernel}/bzImage $out/kernel
  ln -s ${initrd}/initrd $out/initrd
  ln -s ${real-init} $out/init
''
