{ pkgs, top }:

block-devices:

let
  build-one = bd-name: ''
    if [ ! -b "${bd-name}" ]; then
      echo "Building ${bd-name}"
      ${block-devices.${bd-name}.build-command bd-name}
    fi
  '';

  wait-for = bd-name: ''
    while [ ! -b ${bd-name} ]; do
      sleep 0
    done
  '';

  # TODO(low): it would likely be a bit better to wait for a device only just
  # before it is required, and not immediately after building it, for better
  # parallelization
  build-and-wait-for = bd-name:
    pkgs.lib.concatStringsSep "\n" (map (bd-name:
      build-one bd-name + wait-for bd-name
    ) (
      top.lib.sorted-deps-of (a: b: # does a depend on b?
        builtins.elem b block-devices.${a}.depends-on
      ) (builtins.attrNames block-devices) [ bd-name ]
    ));
in
{
  inherit build-and-wait-for;
}
