with (import ../nixtos { pkgs = import <nixpkgs> {}; });

build-vm {
  os = operating-system {
    initrd-modules = [ "virtio_pci" "virtio_blk" "ext4" ];
  };
}
