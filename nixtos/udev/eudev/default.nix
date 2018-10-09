{ pkgs, top }:

{
  init ? "init",
  files ? "files",
  extra-packages ? [],
  extra-path ? [],
}:

_: # TODO(medium): Allow adding udev rules via extenders

let
  packages = [ pkgs.eudev ] ++ extra-packages;

  path = with pkgs; [ coreutils gnused gnugrep utillinux eudev ];

  hwdb = pkgs.runCommand "hwdb.bin" {} ''
    echo "Building link farm..."
    mkdir -p etc/udev/hwdb.d
    ${pkgs.lib.concatMapStringsSep "\n" (x: ''
      for i in ${x}/{etc,var/lib}/udev/hwdb.d/*; do
        ln -s "$i" etc/udev/hwdb.d/"$(basename "$i")"
      done
    '') packages}

    echo "Generating database..."
    ! ${pkgs.eudev}/bin/udevadm hwdb --update --root="$(pwd)" 2>&1 | grep Error

    echo "Everything went well"
    mv etc/udev/hwdb.bin $out
  '';

  rules = pkgs.runCommand "rules.d" {} ''
    ln -s ${pkgs.eudev}/var/lib/udev/rules.d $out
  '';
in

{
  ${init} = { meta.type = "service";
      name = "udev";
      script = ''
        #!${pkgs.bash}/bin/bash

        ${pkgs.eudev}/bin/udevd --debug 2>&1 &
        pid="$!"

        ${pkgs.eudev}/bin/udevadm trigger -c add
        ${pkgs.eudev}/bin/udevadm trigger
        ${pkgs.eudev}/bin/udevadm settle

        wait "$pid"
      '';
      # TODO(medium): should log under ‘log’ user… anyway this should not be
      # tied to runit.
      log-script = ''
        #!${pkgs.bash}/bin/bash

        ${pkgs.coreutils}/bin/mkdir /var/log/eudev
        exec ${pkgs.runit}/bin/svlogd -tt /var/log/eudev
      '';
  };

  ${files} = [
      { meta.type = "symlink";
        file = "/etc/udev/hwdb.bin";
        target = hwdb;
      }
      { meta.type = "symlink";
        file = "/etc/udev/rules.d";
        target = rules;
      }
  ];
}
