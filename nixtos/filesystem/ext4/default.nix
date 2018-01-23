{ pkgs }:

{ block-device }:

{ mountpoint }:

{
  wait-for-block-devices = [ block-device ];

  mount-command = "mount -t ext4 ${block-device} ${mountpoint}";
}
