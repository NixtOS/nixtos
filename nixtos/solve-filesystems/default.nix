{ pkgs, top }:

filesystems:

let
  # List of the mount points
  mountpoints = builtins.attrNames filesystems;

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

  # Returns true iff `b` must be mounted before `a` (ie. `a` depends on `b`)
  depends-on = a: b: builtins.elem b (all-path-deps a);

  # Returns all the parent mount points of a path (including itself).
  all-parent-mount-points = path:
    builtins.filter (x: builtins.elem x mountpoints)
                    (all-parents path ++ [path]);

  # TODO(high): Actually add some wait to check the wait-for-files files are
  # actually present before mounting
  # Returns a script that mounts the passed filesystems in the order given
  mount-fs-list = mountpoints: root:
    pkgs.lib.concatStringsSep "\n" (map (fs:
      "mkdir -p ${root}${fs}\n" +
      filesystems.${fs}.mount-command root fs
    ) mountpoints);

  # The (ordered) list of all filesystems
  all-filesystems = top.lib.sorted-deps-of depends-on mountpoints mountpoints;

  # Returns a script that mounts all filesystems under `root`
  mount-all = root: mount-fs-list all-filesystems root;

  # Returns the (ordered) list of filesystems that have to be mounted in order
  # to access `path`
  filesystems-for = path:
    top.lib.sorted-deps-of depends-on mountpoints (
      all-parent-mount-points path
    );

  # Returns a script that mounts all the filesystems required in order to access
  # `path`
  mount-filesystems-for = path: root: mount-fs-list (filesystems-for path) root;

  # TODO(low): Also handle the case where the user was crazy enough to have a
  # mount point *below* the nix store?
  initrd-block-devices =
    pkgs.lib.flatten (map (x: filesystems.${x}.wait-for-block-devices)
                          (filesystems-for "/nix/store"));
in
{
  inherit initrd-block-devices mount-all mount-filesystems-for;
}
