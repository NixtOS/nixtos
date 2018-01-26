# TODO(medium): Use the VM system as a way to automatically test that NixtOS
# works properly.
let pkgs = import <nixpkgs> {}; in
with (import ../nixtos { inherit pkgs; });

build-vm {
  os = operating-system {
    block-devices = { };
    filesystems = {
      "/" = filesystem.tmpfs {};
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
