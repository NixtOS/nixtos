{ pkgs, top }:

{ block-device }:

{
  wait-for-block-devices = [ block-device ];

  mount-command = mountpoint: "mount -t ext4 ${block-device} ${mountpoint}";
}
