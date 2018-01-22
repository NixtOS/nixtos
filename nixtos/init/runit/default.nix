{ pkgs }:

{
  types = [ "init" ];
  command = "${pkgs.runit}/bin/runit";
}
