{ pkgs }:

{ os }:

let
  # TODO: add os name here
  name = "vm";
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
    -serial mon:stdio
''
