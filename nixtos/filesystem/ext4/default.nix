{ pkgs, top }:

{ block-device }:

{
  wait-for-block-devices = [ block-device ];
  wait-for-files = [];

  extra-modules = [ "ext4" ];

  mount-command = mountpoint: "mount -t ext4 ${block-device} ${mountpoint}";
}
