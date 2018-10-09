{ pkgs, top }:

rec {
  # Configuration helpers
  # =====================

  # users: ({ name:string, users:list user } | list user) -> service
  # TODO(low): typecheck?
  users = arg: # TODO(low): abstract this away from unix? will be hard
  if builtins.isList arg then users { name = "users"; users = arg; }
  else
    _ignored_extenders:
    builtins.map (user: {
      extends = arg.name;
      data = user // {
        type = "user";
      };
    }) arg.users;

  # Main implementation functor
  # ===========================

  __functor = self: {
    files ? "files"
  }:

  extenders:

  # TODO(low): Allow for imperative-style user&group definition
  let
    default-user = {
      # ‘user’ has no default value
      # ‘password-hash’ has no default value
      # TODO(medium): ‘uid’ has no default value for the time being
      # TODO(medium): ‘gid’ should actually be given by group name
      gecos = "";
      home = "/var/empty";
      shell = "/run/current-system/sw/bin/nologin"; # TODO(high): this file doesn't actually exist
    };

    # TODO(low): this builtins.all should be a call to lib.make-attrset for better
    # error reporting
    passwd-list =
      assert builtins.all (e:
        1 == pkgs.lib.count (x: x.user == e.user) extenders &&
        1 == pkgs.lib.count (x: x.uid == e.uid) extenders
      ) extenders;
      map (ext:
        assert ext.type == "user";
        let e = default-user // ext; in
        "${e.user}:x:${toString e.uid}:${toString e.gid}:${e.gecos}:${e.home}:${e.shell}"
      ) extenders;

    passwd-text = pkgs.lib.concatStringsSep "\n" passwd-list;

    shadow-list = map (e: "${e.user}:${e.password-hash}:::::::") extenders;

    shadow-text = pkgs.lib.concatStringsSep "\n" shadow-list;
  in
  [
    { extends = files;
      data = {
        type = "symlink";
        file = "/etc/passwd";
        target = pkgs.writeText "passwd" passwd-text;
      };
    }

    # TODO(high): make /etc/shadow non-world-readable? all the data in it is
    # accessible from the store anyway, so…
    { extends = files;
      data = {
        type = "symlink";
        file = "/etc/shadow";
        target = pkgs.writeText "shadow" shadow-text;
      };
    }
  ];
}
