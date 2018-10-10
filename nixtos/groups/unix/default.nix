{ pkgs, top }:

rec {
  # Configuration helpers
  # =====================

  # groups: ({ name:string, groups:list group } | list group) -> service
  # TODO(low): typecheck?
  groups = arg: # TODO(low): abstract this away from unix?
  if builtins.isList arg then groups { name = "groups"; groups = arg; }
  else
    _ignored_extenders:
    {
      ${arg.name} =
        builtins.map (group: group // { type = "group"; }) arg.groups;
    };

  # Main implementation functor
  # ===========================

  __functor = self: {
    files ? "files"
  }:

  extenders:

  # TODO(low): Allow for imperative-style user&group definition
  # TODO(medium): The ‘users’ parameter should not be given here, but as an
  # ‘extra-groups’ parameter of the user (ie. as extenders).
  # TODO(medium): ‘gid’ should have a default value
  let
    # TODO(low): this builtins.all should be a call to lib.make-attrset for better
    # error reporting
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
  {
    ${files} = {
      type = "symlink";
      file = "/etc/group";
      target = pkgs.writeText "group" group-text;
    };
  };
}
