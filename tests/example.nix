let pkgs = import <nixpkgs> {}; in
with (import ../nixtos { inherit pkgs; });

build-vm {
  os = operating-system {
    initrd-modules = [ "virtio_pci" "virtio_blk" "ext4" ];
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
