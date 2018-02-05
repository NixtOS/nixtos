{ pkgs, top }:

{
  agetty = import ./agetty { inherit pkgs top; };
}
