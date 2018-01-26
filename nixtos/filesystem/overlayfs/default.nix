{ pkgs, top }:

{ lower, upper, work }:

{
  wait-for-block-devices = [];
  wait-for-files = [ lower upper work ];

  extra-modules = [ "overlay" ];

  # TODO(medium): remove these mkdir -p?
  mount-command = root: mount: ''
    mkdir -p ${root}${lower} ${root}${upper} ${root}${work}
    mount -t overlay none ${root}${mount} \
      -o lowerdir=${root}${lower},upperdir=${root}${upper},workdir=${root}${work}
  '';
}
