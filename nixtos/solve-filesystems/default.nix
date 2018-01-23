{ pkgs, top }:

filesystems:

# TODO: actually solve the filesystems
let
  initrd-block-devices = filesystems."/".wait-for-block-devices;
in
{
  inherit initrd-block-devices;
}
