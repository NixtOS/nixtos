{ pkgs, hooks ? {} }:

let
  top = pkgs.lib.recursiveUpdate {
    block-device = import ./block-device { inherit pkgs top; };
    build-vm = import ./build-vm { inherit pkgs top; };
    files = import ./files { inherit pkgs top; };
    filesystem = import ./filesystem { inherit pkgs top; };
    make-initrd = import ./make-initrd { inherit pkgs top; };
    init = import ./init { inherit pkgs top; };
    operating-system = import ./operating-system { inherit pkgs top; };
    solve-services = import ./solve-services { inherit pkgs top; };
    version = import ./version { inherit pkgs top; };
  } hooks;
in
  top
