{ pkgs, top }:

{
  os,
  extra-cmdline-args ? "",
  qemu ? "${pkgs.kvm}/bin/qemu-kvm",
  cpu ? "host",
  memory ? "1G",
  ncpu ? 1,
  drives,
}:

let
  name = "vm-${os.name}";

  store-paths = pkgs.closureInfo { rootPaths = [ os ]; };

  store = pkgs.runCommand "store-${name}" {} ''
    mkdir $out
    cp -r $(cat ${store-paths}/store-paths) $out
  '';

  drive-builders = pkgs.lib.concatStringsSep "\n" (
    map (f: (f { inherit store; }).build) drives
  );

  drive-options = pkgs.lib.concatStringsSep " \\\n  " (
    map (f: (f { inherit store; }).options) drives
  );
in
pkgs.writeScript name ''
  #!${pkgs.bash}/bin/bash

  ${drive-builders}

  exec ${pkgs.kvm}/bin/qemu-kvm \
    -cpu ${cpu} \
    -name ${name} \
    -m ${memory} \
    -smp ${toString ncpu} \
    -kernel ${os}/kernel \
    -initrd ${os}/initrd \
    -append 'real-init=${os}/init console=ttyS0 ${extra-cmdline-args}' \
    -serial mon:stdio \
    ${drive-options}
''
