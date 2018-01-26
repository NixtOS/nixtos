{ pkgs, top }:

{
  ext4 = import ./ext4 { inherit pkgs top; };
  tmpfs = import ./tmpfs { inherit pkgs top; };
  virtfs = import ./virtfs { inherit pkgs top; };
}
