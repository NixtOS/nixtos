{ pkgs, top }:

{ block-device }:

{
  wait-for-block-devices = [ block-device ];

  extra-modules = [ "ext4" ];

  mount-command = mountpoint: "mount -t ext4 ${block-device} ${mountpoint}";
}
