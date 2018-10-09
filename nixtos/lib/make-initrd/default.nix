{ pkgs, top }:
{ kernel, modules, block-devices, filesystems }:

let
  module-closure = pkgs.makeModulesClosure {
    kernel = kernel;
    rootModules = modules;
    firmware = kernel; # TODO(medium): this should be set-able
  };

  solved-block-devices = top.lib.solve-block-devices block-devices;

  solved-filesystems = top.lib.solve-filesystems filesystems;

  # TODO(medium): add a check so that different libraries imported with the same
  # name couldn't conflict
  utils = pkgs.runCommandCC "initrd-utils" {
    buildInputs = [ pkgs.nukeReferences pkgs.glibc ];
    allowedReferences = [ "out" ];
  } ''
    echo "Setting up the environment"
    mkdir -p $out/{bin,lib}
    function copy_bin() {
      cp -fpd "$@" $out/bin
    }
    function copy_lib() {
      cp -fpdL "$@" $out/lib
    }
    export -f copy_lib

    echo "Copying BusyBox"
    copy_bin ${pkgs.busybox}/bin/*

    echo "Copying kmod"
    copy_bin ${pkgs.kmod}/bin/kmod
    ln -sf kmod $out/bin/modprobe

    echo "Copying relevant libraries"
    copy_lib ${pkgs.glibc.out}/lib/ld*.so.?
    find $out/{bin,lib} -type f | while read f; do
      ldd "$f" | \
        awk '{ if ($3 != "") print $3 }' | \
        xargs -n 1 -I {} bash -c "copy_lib {}" \
        || true # Error here basically means static executable
    done

    echo "Stripping down everything"
    chmod -R u+w $out
    stripDirs "lib bin" "-s"

    echo "Nuke references to everything but us"
    find $out/{bin,lib} -type f | xargs -n 1 nuke-refs -e $out

    echo "Reset interpreter"
    find $out/{bin,lib} -type f | \
      xargs -n 1 patchelf --set-interpreter $out/lib/ld*.so.? \
                          --set-rpath $out/lib \
      || true # Error here basically means static executable or library

    echo "Testing patched programs"
    $out/bin/ash -c 'echo "Test"' | grep 'Test' > /dev/null
    $out/bin/kmod -h | grep 'Usage:' > /dev/null
    $out/bin/modprobe -h | grep 'Usage:' > /dev/null
  '';

  # TODO(low): Handle the case where someone was crazy enough to have a mount
  # point *below* /nix/store?
  # TODO(medium): Make command executed on error configurable
  init = pkgs.writeScript "initrd-init" ''
    #!${utils}/bin/ash -e
    PATH="${utils}/bin"

    function error_occured() {
        exec env PATH=$PATH ash
    }
    trap error_occured EXIT

    echo "Setting up basic environment"
    mount -t devtmpfs none /dev
    mount -t proc none /proc
    mount -t sysfs none /sys

    echo "Parsing command-line arguments"
    for opt in $(cat /proc/cmdline); do
      case $opt in
        init=*)
          init="$(echo "$opt" | sed 's/.*=//')"
          echo "Found init ‘$init’"
          ;;
      esac
    done

    echo "Loading requested modules"
    mkdir /lib
    ln -s ${module-closure}/lib/modules /lib/modules
    ${pkgs.lib.concatStringsSep "\n" (map (mod: "modprobe ${mod}") modules)}

    echo "Building block devices"
    ${pkgs.lib.concatStringsSep "\n" (
        map solved-block-devices.build-and-wait-for
            solved-filesystems.initrd-block-devices
      )}

    echo "Mounting filesystems"
    ${solved-filesystems.mount-filesystems-for "/nix/store" "/real-root"}

    echo "Cleaning up"
    umount /sys
    umount /proc
    umount /dev

    echo "Switching to on-disk init"
    exec switch_root /real-root $init
  '';
in
pkgs.makeInitrd {
  contents = [
    { object = init;
      symlink = "/init";
    }
  ];
}
