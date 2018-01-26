{ pkgs, top }:

{ block-device }:

{
  wait-for-block-devices = [ block-device ];
  wait-for-files = [];

  extra-modules = [ "ext4" ];

  mount-command = root: mount: "mount -t ext4 ${block-device} ${root}${mount}";
}
