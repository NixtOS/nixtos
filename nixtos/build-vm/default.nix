# TODO(low): this is *very* centered on testing while developing. Allowing to
# use different disks than one fixed in the store should already help
{ pkgs, top }:

{
  os,
  extra-cmdline-args ? "",
  qemu ? "${pkgs.kvm}/bin/qemu-kvm",
  cpu ? "host",
  memory ? "1G",
  ncpu ? 1,
}:

let
  name = "vm-${os.name}";

  store = pkgs.runCommand "store-${name}" {
    exportReferencesGraph = [ "closure" os ];
  } ''
    mkdir $out
    cp -r $(${pkgs.perl}/bin/perl ${pkgs.pathsFromGraph} closure) $out
  '';
in
pkgs.writeScript name ''
  #!${pkgs.bash}/bin/bash

  exec ${pkgs.kvm}/bin/qemu-kvm \
    -cpu ${cpu} \
    -name ${name} \
    -m ${memory} \
    -smp ${toString ncpu} \
    -kernel ${os}/kernel \
    -initrd ${os}/initrd \
    -append 'real-init=${os}/init console=ttyS0 ${extra-cmdline-args}' \
    -serial mon:stdio \
    -virtfs local,mount_tag=store,path=${store},security_model=none
''
