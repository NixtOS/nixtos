{ pkgs }:
{ kernel }:

let
  modules = pkgs.makeModulesClosure {
    kernel = kernel;
    rootModules = [ "virtio_pci" "virtio_blk" "ext4" ]; # TODO: make this configurable
  };

  # TODO: build busybox as static and make sure that glibc no longer is in the
  # closure (just building busybox as static isn't enough)
  # TODO: get rid of these ugly “virtio_blk: Unknown symbol
  # register_virtio_driver (err 0)” & co. errors (by switching to non-busybox
  # modprobe? see [1])
  # [1] https://github.com/quitesimpleorg/N900_RescueOS/commit/0c3ce0d7b46a32e460a4ba6dd8f2799cd68c5c33
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
    mkdir /lib
    ln -s ${modules}/lib/modules /lib/modules
    modprobe virtio_pci
    modprobe virtio_blk
    modprobe ext4

    echo "Mounting root filesystem"
    mkdir /real-root
    mount /dev/vda /real-root

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
