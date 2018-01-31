# TODO(high): Add the equivalent of nixos-rebuild

{ pkgs, hooks ? {} }:

# TODO(low): Cleanup this list by moving things to their right place
let
  top = pkgs.lib.recursiveUpdate {
    basic-system = import ./basic-system { inherit pkgs top; };
    block-device = import ./block-device { inherit pkgs top; };
    bootloader = import ./bootloader { inherit pkgs top; };
    bootloaders = import ./bootloaders { inherit pkgs top; };
    build-vm = import ./build-vm { inherit pkgs top; };
    files = import ./files { inherit pkgs top; };
    filesystem = import ./filesystem { inherit pkgs top; };
    make-initrd = import ./make-initrd { inherit pkgs top; };
    init = import ./init { inherit pkgs top; };
    lib = import ./lib { inherit pkgs top; };
    operating-system = import ./operating-system { inherit pkgs top; };
    solve-block-devices = import ./solve-block-devices { inherit pkgs top; };
    solve-filesystems = import ./solve-filesystems { inherit pkgs top; };
    solve-services = import ./solve-services { inherit pkgs top; };
    version = import ./version { inherit pkgs top; };
    vm-drive = import ./vm-drive { inherit pkgs top; };
  } hooks;
in
  top
