{ pkgs, top }:

{
  empty-drive = import ./empty-drive { inherit pkgs top; };
  virtfs-to-store = import ./virtfs-to-store { inherit pkgs top; };
}
