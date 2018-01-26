{ pkgs, top }:

{ tag }:

# TODO(low): Figure out how to wait on something (file?) to be sure the fs
# can be mounted before trying to mount it (but I can't imagine a way for the fs
# not to be ready just after modprobe, so that's likely not a top-priority
# issue)
{
  wait-for-block-devices = [];
  wait-for-files = [];

  extra-modules = [ "9p" "9pnet_virtio" "virtio_pci" ];

  # Accoding to The Internet™, 256KiB (= 262144B) works pretty well
  mount-command = root: mount: ''
    mount -t 9p -o trans=virtio,version=9p2000.L,msize=262144 ${tag} ${root}${mount}
  '';
}
