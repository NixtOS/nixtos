let pkgs = import <nixpkgs> {}; in
with (import ../../nixtos { inherit pkgs; });

operating-system {
  block-devices = {
    "/dev/vda" = block-devices.virtio-disk {};
  };
  filesystems = {
    "/" = filesystem.ext4 { block-device = "/dev/vda2"; };
    "/boot" = filesystem.ext4 { block-device = "/dev/vda1"; };
  };
  packages = with pkgs; [ bash coreutils ];
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
}
