{ pkgs, top }:

{
  init ? "init",
  try-to-keep-baud ? true,
  baud-rates ? [ 115200 38400 9600 ],
}:

tty:

extenders:

[
  { extends = init;
    data = {
      type = "service";
      name = "agetty-${tty}";
      script = ''
        #!${pkgs.bash}/bin/bash

        exec ${pkgs.utillinux}/bin/agetty \
          --login-program ${pkgs.shadow}/bin/login \
          --noclear \
          ${pkgs.lib.optionalString try-to-keep-baud "--keep-baud"} \
          ${tty} \
          ${pkgs.lib.concatMapStringsSep "," toString baud-rates}
      '';
      # TODO(medium): should log under ‘log’ user… anyway this should not be
      # tied to runit.
      log-script = ''
        #!${pkgs.bash}/bin/bash

        ${pkgs.coreutils}/bin/mkdir /var/log/agetty-${tty}
        exec ${pkgs.runit}/bin/svlogd -tt /var/log/agetty-${tty}
      '';
    };
  }
]
