{ pkgs }:

let
  # TODO: build busybox as static and make sure that glibc no longer is in the
  # closure (just building busybox as static isn't enough)
  initrd-init = pkgs.writeScript "initrd-init" ''
    #!${pkgs.busybox}/bin/sh
    PATH="${pkgs.busybox}/bin"

    # Setup basic environment
    mount -t devtmpfs none /dev
    mount -t proc none /proc
    mount -t sysfs none /sys

    # Parse command-line arguments
    for o in `cat /proc/cmdline`; do
      case $o in
        real-init=*)
          set -- `sh -c "IFS='='; echo $o"`
          real_init="$2"
          ;;
        console=*)
          ;;
        *)
          echo -e "Failed to understand parameter ‘$o’!"
          ;;
      esac
    done

    # Get the root ready
    mkdir /real-root
    echo "/dev:"
    ls /dev

    echo "Store of the initrd:"
    ls /nix/store

    mount /dev/sda /real-root

    # Cleanup
    umount /sys
    umount /proc
    umount /dev

    # And switch to the real environment
    exec switch_root /real-root $real_init
  '';
in
pkgs.makeInitrd {
  contents = [
    { object = initrd-init;
      symlink = "/init";
    }
  ];
}
