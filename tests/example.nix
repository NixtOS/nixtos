# TODO(medium): Use the VM system as a way to automatically test that NixtOS
# works properly.
let pkgs = import <nixpkgs> {}; in
with (import ../nixtos { inherit pkgs; });

let
  drives = [
    (vm-drive.virtfs-to-store { tag = "store"; })
    (vm-drive.virtfs { tag = "config"; path = ./example; rw = false; })
    (vm-drive.guestfish {
      name = "test.img";
      persist = true;
      script = ''
        disk-create test.img qcow2 2G
        add test.img
        run
        part-init /dev/sda mbr
        part-add /dev/sda p 2048 4096
        part-add /dev/sda p 4097 -2048
        mke2fs /dev/sda1
        mke2fs /dev/sda2
      '';
    })
  ];
in

build-vm {
  inherit drives;

  net = "user";

  os = operating-system {
    block-devices = {
      "/dev/vda" = block-device.virtio-disk {};
    };
    filesystems = {
      "/" = filesystem.tmpfs {};
      "/boot" = filesystem.ext4 { block-device = "/dev/vda1"; };
      "/nix/.ro-store" = filesystem.virtfs { tag = "store"; };
      "/config" = filesystem.virtfs { tag = "config"; };
      "/nix/store" = filesystem.overlayfs {
        lower = "/nix/.ro-store";
        upper = "/nix/.rw-store";
        work = "/nix/.work-store";
      };
    };
    packages = with pkgs; [
      (pkgs.lib.lowPrio busybox)
      bash coreutils curl dhcpcd gnugrep iproute kmod nix procps pstree strace
    ];
    services = core-system {
      ttys = { ttyS0 = tty.agetty {}; };
    } {
      test-env = pam.env [ { # TODO(high): this should be by default
        name = "PATH";
        value = "/run/current-system/sw/bin";
      } ];
      test-users = users.unix.users [ # TODO(high): this should find a home somewhere
        { user = "root";
          password-hash = "$5$fl7YR8nFD0jQJ$mja7t27ZM2yTTPwWeotJ2cEumZxk6a5uSiHC8i1PCN."; # "test"
          home = "/root";
          shell = "/run/current-system/sw/bin/bash";
          uid = 0;
          gid = 0;
        }
        { user = "nixbld1";
          password-hash = "x";
          uid = 1;
          gid = 2;
        }
      ];
      test-groups = _: [ {
        extends = "groups";
        data = [
          { type = "group";
            group = "root";
            gid = 0;
            users = [ "root" ];
          }
          { type = "group";
            group = "wheel";
            gid = 1;
            users = [ "root" ];
          }
          { type = "group";
            group = "nixbld";
            gid = 2;
            users = [ "nixbld1" ];
          }
        ];
      } ];
    };
  };
}
