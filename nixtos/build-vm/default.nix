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
  extra-qemu-args ? "",
}:

let
  name = "vm-${os.name}";

  # TODO(medium): use a virtfs instead of an image built with libguestfs?
  store-image = pkgs.runCommand "store-image.raw" {
    # TODO(low): fix (and upstream) the packaging of libguestfs so that this
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

  cp ${store-image} "${name}.qcow2"
  chmod u+w "${name}.qcow2"

  exec ${pkgs.kvm}/bin/qemu-kvm \
    -cpu ${cpu} \
    -name ${name} \
    -m ${memory} \
    -smp ${toString ncpu} \
    -kernel ${os}/kernel \
    -initrd ${os}/initrd \
    -append 'real-init=${os}/init console=ttyS0 ${extra-cmdline-args}' \
    -serial mon:stdio \
    -drive file="${name}.qcow2",if=virtio \
    ${extra-qemu-args}
''
