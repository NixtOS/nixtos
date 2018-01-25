# TODO(medium): Use the VM system as a way to automatically test that NixtOS
# works properly.
let pkgs = import <nixpkgs> {}; in
with (import ../nixtos { inherit pkgs; });

build-vm {
  os = operating-system {
    block-devices = {
      "/dev/vda" = block-device.virtio-disk {};
    };
    filesystems = {
      "/" = filesystem.ext4 { block-device = "/dev/vda"; };
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
