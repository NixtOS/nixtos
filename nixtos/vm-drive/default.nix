{ pkgs, top }:

{
  virtfs-to-store = import ./virtfs-to-store { inherit pkgs top; };
}
