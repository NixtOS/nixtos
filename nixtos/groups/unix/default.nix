{ pkgs, top }:

{ files ? "files" }:

extenders:

# TODO(low): Allow for imperative-style user&group definition
# TODO(medium): The ‘users’ parameter should not be given here, but as an
# ‘extra-groups’ parameter of the user (ie. as extenders).
# TODO(medium): ‘gid’ should have a default value
let
  group-list =
    assert builtins.all (e:
      1 == pkgs.lib.count (x: x.group == e.group) extenders &&
      1 == pkgs.lib.count (x: x.gid == e.gid) extenders
    ) extenders;
    map (e:
      assert e.type == "group";
      let users = pkgs.lib.concatStringsSep "," e.users; in
      "${e.group}:x:${toString e.gid}:${users}"
    ) extenders;

  group-text = pkgs.lib.concatStringsSep "\n" group-list;
in
[
  { extends = files;
    data = {
      type = "symlink";
      file = "/etc/group";
      target = pkgs.writeText "group" group-text;
    };
  }
]
