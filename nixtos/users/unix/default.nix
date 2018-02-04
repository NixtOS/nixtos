{ pkgs, top }:

{ files ? "files" }:

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
    shell = "/run/current-system/sw/bin/nologin";
  };

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
]
