# TODO: this is *very* centered on testing while developing. Allowing to use
# different disks than one fixed in the store should already help
{ pkgs }:

{
  os,
  extra-cmdline-args ? "",
  qemu ? "${pkgs.kvm}/bin/qemu-kvm",
  cpu ? "host",
  memory ? "1G",
  ncpu ? 1,
  extra-qemu-args ? "",
}:

let
  # TODO: add os name here
  name = "vm";

  store-image = pkgs.runCommand "store-image.raw" {
    # TODO: fix (and upstream) the packaging of libguestfs so that this
    # buildInput is no longer needed
    buildInputs = with pkgs; [ file ];
    exportReferencesGraph = [ "closure" os ];
  } ''
    tar czf root.tgz $(${pkgs.perl}/bin/perl ${pkgs.pathsFromGraph} closure)
    ${pkgs.libguestfs}/bin/virt-make-fs root.tgz $out
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
    -drive file=${store-image},if=virtio,readonly \
    ${extra-qemu-args}
''
