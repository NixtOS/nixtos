{ pkgs }:

let
  # TODO: build busybox as static and make sure that glibc no longer is in the
  # closure (just building busybox as static isn't enough)
  init = pkgs.writeScript "initrd-init" ''
    #!${pkgs.busybox}/bin/sh
    PATH="${pkgs.busybox}/bin"

    echo "Setting up basic environment"
    mount -t devtmpfs none /dev
    mount -t proc none /proc
    mount -t sysfs none /sys

    echo "Parsing command-line arguments"
    for opt in $(cat /proc/cmdline); do
      case $opt in
        real-init=*)
          real_init="$(echo "$opt" | sed 's/.*=//')"
          echo "Found real init ‘$real_init’"
          ;;
      esac
    done

    echo "Loading requested modules"
    mkdir /real-root
    echo "/dev:"
    ls /dev

    echo "Store of the initrd:"
    ls /nix/store

    echo "Mounting root filesystem"
    mount /dev/sda /real-root

    echo "Cleaning up"
    umount /sys
    umount /proc
    umount /dev

    echo "Switching to on-disk init"
    exec switch_root /real-root $real_init
  '';
in
pkgs.makeInitrd {
  contents = [
    { object = init;
      symlink = "/init";
    }
  ];
}
