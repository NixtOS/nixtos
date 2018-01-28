# TODO(medium): Use the VM system as a way to automatically test that NixtOS
# works properly.
let pkgs = import <nixpkgs> {}; in
with (import ../nixtos { inherit pkgs; });

build-vm {
  drives = [
    (vm-drive.virtfs-to-store { tag = "store"; })
    (vm-drive.guestfish {
      name = "test.img";
      persist = true;
      script = ''
        disk-create test.img qcow2 2G
        add test.img
        run
        part-init /dev/sda mbr
        part-add /dev/sda p 2048 -2048
        mke2fs /dev/sda1
      '';
    })
  ];
  os = operating-system {
    block-devices = {
      "/dev/vda" = block-device.virtio-disk {};
    };
    filesystems = {
      "/" = filesystem.tmpfs {};
      "/boot" = filesystem.ext4 { block-device = "/dev/vda1"; };
      "/nix/.ro-store" = filesystem.virtfs { tag = "store"; };
      "/nix/store" = filesystem.overlayfs {
        lower = "/nix/.ro-store";
        upper = "/nix/.rw-store";
        work = "/nix/.work-store";
      };
    };
    services = basic-system {} {
      example-service = _: [
        { extends = "init";
          data = {
            type = "service";
            name = "example";
            script = ''
              #!${pkgs.bash}/bin/bash

              echo "This is a test service running! (but dying too early)"
            '';
          };
        }
      ];
    };
  };
}
