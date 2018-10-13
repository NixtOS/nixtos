{ pkgs, top }:

rec {
  env = import ./env.nix { inherit pkgs top; };

  # Main implementation functor
  # ===========================

  __functor = self: {
    files ? "files",
    config ? {},
  }:

  extenders: # TODO(medium): Allow adding PAM configuration via extenders

  let
    env = top.lib.make-attrset (e:
      throw "Trying to define the same session environment variable at multiple positions: ${builtins.toJSON e}"
    ) (builtins.map (e:
      { name = e.name; value = e; }
    ) (builtins.filter (e:
      e.meta.type == "env"
    ) extenders));

    env-file = pkgs.writeText "pam-env" (
      builtins.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (var: d:
        "${var}=${d.value}"
      ) env)
    );

    cfg = {
      other = ''
        auth      required   pam_warn.so
        auth      requisite  pam_deny.so

        account   required   pam_warn.so
        account   requisite  pam_deny.so

        password  required   pam_warn.so
        password  requisite  pam_deny.so

        session   required   pam_deny.so
        session   requisite  pam_warn.so
      '';

      login = ''
        account sufficient pam_unix.so

        auth sufficient pam_unix.so
        auth requisite pam_deny.so

        password requisite pam_unix.so sha512

        session required pam_env.so envfile=${env-file}
        session required pam_unix.so
        session required pam_loginuid.so
        session required pam_lastlog.so
      '';
    } // config;
  in
  {
    ${files} = pkgs.lib.mapAttrsToList (service: conf:
      { meta.type = "symlink";
        file = "/etc/pam.d/${service}";
        target = pkgs.writeScript "pam-${service}" conf;
      }
    ) cfg;
  };
}
