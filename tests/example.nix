let pkgs = import <nixpkgs> {}; in
with (import ../nixtos { inherit pkgs; });

build-vm {
  os = operating-system {
    initrd-modules = [ "ext4" ];
    block-devices = {
      "/dev/vda" = block-device.virtio-disk {};
    };
    services = {
      files = files {};
      init = init.runit {};
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
