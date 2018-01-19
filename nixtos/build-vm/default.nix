# TODO: this is *very* centered on testing while developing.
{ pkgs }:

{ os }:

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
# TODO: do not hardcode amd64 etc. here
pkgs.writeScript name ''
  #!${pkgs.bash}/bin/bash

  exec ${pkgs.kvm}/bin/qemu-kvm \
    -cpu kvm64 \
    -name ${name} \
    -m 1024 \
    -smp 1 \
    -kernel ${os}/kernel \
    -initrd ${os}/initrd \
    -append 'real-init=${os}/init console=ttyS0 foo=bar' \
    -serial mon:stdio \
    -drive file=${store-image},if=virtio,readonly
''
