{ pkgs, top }:

filesystems:

# TODO(high): Separate mount-fs-required-for-initrd and mount-all-fs options
let
  # TODO(high): Actually handle mounting everything
  initrd-block-devices = filesystems."/".wait-for-block-devices;

  # Returns all parent directories (excluding the path itself) of a path.
  all-parents = path:
    if path == "/" then [ ]
    else all-parents (dirOf path) ++ [ (dirOf path) ];

  # Returns all paths that must be present in order to mount a filesystem.
  # This only gives “leaf” paths.
  all-leaf-deps = mount: filesystems.${mount}.wait-for-files ++ [ mount ];

  # Returns all paths that must be present in order to mount a filesystem,
  # including parent paths.
  all-path-deps = mount: pkgs.lib.flatten (
    map all-parents (all-leaf-deps mount)
  );

  # Sorts mount points by dependence order
  sort-mount-points = mountpoints: (pkgs.lib.toposort (before: after:
    builtins.elem before (all-path-deps after)
  ) mountpoints).result;

  # Returns a script that mounts all filesystems under `root`
  mount-all = root:
    pkgs.lib.concatStringsSep "\n" (map (fs:
      "mkdir -p ${root}${fs}\n" +
      filesystems.${fs}.mount-command (root + fs)
    ) (sort-mount-points (builtins.attrNames filesystems)));
in
{
  inherit initrd-block-devices mount-all;
}
