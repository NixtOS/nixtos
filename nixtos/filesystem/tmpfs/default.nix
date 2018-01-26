{ pkgs, top }:

{ size ? null }:

let
  sz = if size == null then "50%" else toString size;
in
{
  wait-for-block-devices = [];
  wait-for-files = [];

  extra-modules = [];

  mount-command = root: mount:
    "mount -t tmpfs -o size=${sz} none ${root}${mount}";
}
