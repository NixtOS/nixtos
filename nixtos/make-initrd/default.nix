{ pkgs }:
{ kernel, modules }:

let
  module-closure = pkgs.makeModulesClosure {
    kernel = kernel;
    rootModules = modules;
  };

  # TODO: add a check so that different libraries imported with the same name
  # couldn't conflict
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
    for f in ${pkgs.busybox}/{s,}bin/*; do
      copy_bin "$f"
    done

    echo "Copying relevant libraries"
    copy_lib ${pkgs.glibc.out}/lib/ld*.so.?
    find $out/{bin,lib} -type f | while read f; do
      ldd "$f" | \
        awk '{ if ($3 != "") print $3 }' | \
        xargs -I {} bash -c "copy_lib {}" \
        || true # Error here basically means static executable
    done

    echo "Stripping down everything"
    chmod -R u+w $out
    stripDirs "lib bin" "-s"

    echo "Nuke references to everything but us"
    find $out/{bin,lib} -type f | xargs nuke-refs -e $out

    echo "Reset interpreter"
    find $out/{bin,lib} -type f | \
      xargs patchelf --set-interpreter $out/lib/ld*.so.? --set-rpath $out/lib \
      || true # Error here basically means static executable

    echo "Testing patched programs"
    $out/bin/ash -c 'echo "Test"' | grep 'Test' > /dev/null
  '';

  # TODO: get rid of these ugly “virtio_blk: Unknown symbol
  # register_virtio_driver (err 0)” & co. errors (by switching to non-busybox
  # modprobe? see [1])
  # [1] https://github.com/quitesimpleorg/N900_RescueOS/commit/0c3ce0d7b46a32e460a4ba6dd8f2799cd68c5c33
  init = pkgs.writeScript "initrd-init" ''
    #!${utils}/bin/ash
    PATH="${utils}/bin"

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
    ln -s ${module-closure}/lib/modules /lib/modules
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
