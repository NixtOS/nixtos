with (import ../nixtos {});

build-vm {
  os = operating-system {
    initrd-modules = [ "virtio_pci" "virtio_blk" "ext4" ];
  };
}
