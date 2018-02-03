# TODO(medium): Use the VM system as a way to automatically test that NixtOS
# works properly.
let pkgs = import <nixpkgs> {}; in
with (import ../nixtos { inherit pkgs; });

let
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

  bootloader-install-script = bootloaders [
    (bootloader.grub-bios {
      block-device = "/dev/vda";
      config-dir = "/boot";
      config-dir-grub-device = "(hd0,msdos1)";
      config-dir-grub-dir = "/";
      os = os-with-init (init.runit {});
    })
  ];

  os-with-init = init: operating-system {
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
    packages = with pkgs; [
      bash
      coreutils
    ];
    services = basic-system { inherit init; } {
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
in

build-vm {
  inherit drives;

  os = os-with-init (_: [ {
    extends = "kernel";
    data = {
      type = "init";
      command = pkgs.writeScript "init" ''
        #!${pkgs.bash}/bin/bash
        export PATH=${pkgs.grub2}/bin:/run/current-system/sw/bin

        echo "---- Run ${bootloader-install-script} to install bootloaders"

        exec bash
      '';
    };
  } ]);
}
