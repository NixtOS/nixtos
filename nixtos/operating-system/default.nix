{ pkgs }:
{
  kernel ? pkgs.linuxPackages.kernel,
}:

let
  mkInitrd = import ../make-initrd { inherit pkgs; };

  # TODO: add nixtos version here
  version = "nixtos-${pkgs.lib.nixpkgsVersion}";

  real-init = pkgs.writeScript "real-init" ''
    #!${pkgs.busybox}/bin/sh

    echo "In real init!"

    while true; do
      sleep 1
    done
  '';

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

    echo "Store of the initrd:"
    ls /nix/store

    # Cleanup
    umount /sys
    umount /proc
    umount /dev

    # And switch to the real environment
    exec switch_root /real-root $real_init
  '';

  initrd = pkgs.makeInitrd {
    contents = [
      { object = initrd-init;
        symlink = "/init";
      }
    ];
  };
in
pkgs.runCommand version {} ''
  mkdir $out
  ln -s ${kernel}/bzImage $out/kernel
  ln -s ${initrd}/initrd $out/initrd
  ln -s ${real-init} $out/init
''
