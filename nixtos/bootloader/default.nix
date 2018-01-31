{ pkgs, top }:

{
  grub-bios = import ./grub-bios { inherit pkgs top; };
}
