{ pkgs, top }:

{
  files ? "files",
  config ? {},
}:

_: # TODO(medium): Allow adding configuration via extenders

let
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

      # TODO(high): session environment
      session required pam_unix.so
      session required pam_loginuid.so
      # TODO(medium): session required pam_lastlog.so
    '';
  } // config;
in
[
  { extends = files;
    data = pkgs.lib.mapAttrsToList (service: conf:
      { type = "symlink";
        file = "/etc/pam.d/${service}";
        target = pkgs.writeScript "pam-${service}" conf;
      }
    ) cfg;
  }
]
