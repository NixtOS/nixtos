{ pkgs, top }:

{
  assertions ? "assertions",
  kernel ? "kernel",
  files ? "files",
} @ args:

extenders:

let
  asserts = with top.lib.types;
    assert-type "nixtos.init.runit's argument" args (product-opt {
      req = {};
      opt = {
        kernel = string;
        files = string;
        assertions = string;
      };
    });

  # TODO(medium): compute `name` from the service name + given name
  services = top.lib.make-attrset (s:
    throw "Trying to define the same services at multiple locations: ${builtins.toJSON s}"
  ) (map (e: { name = e.name; value = e; }) extenders);

  services-dir =
    pkgs.runCommand "runit-services" {} (
      ''
        mkdir $out
      '' + pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (service: d:
        # TODO(low): Currently this leads to a shell script exec'ing a shell
        # script exec'ing the result, thus one unneeded level of indirection
        # TODO(high): The ‘log-script’ thing is tightly linked with runit. It
        # shouldn't be.
        assert d.meta.type == "service"; ''
          mkdir "$out/${service}"

          ln -s "/run/runit/supervise-${service}" \
                "$out/${service}/supervise"

          cat > "$out/${service}/run" <<EOF
          #!${pkgs.bash}/bin/bash

          exec ${pkgs.writeScript "runit-init-${service}" d.script}
          EOF
          chmod +x "$out/${service}/run"

          mkdir "$out/${service}/log"
          cat > "$out/${service}/log/run" <<EOF
          #!${pkgs.bash}/bin/bash

          exec ${pkgs.writeScript "runit-log-${service}" d.log-script}
          EOF
          chmod +x "$out/${service}/log/run"
        ''
      ) services)
    );
in
{
  ${assertions} = asserts;

  ${kernel} = {
    meta.type = "init";
    command = "${pkgs.runit}/bin/runit";
  };

  ${files} = [
    { meta.type = "symlink";
      file = "/etc/runit/1";
      target = pkgs.writeScript "runit-1" "#!${pkgs.bash}/bin/bash";
    }
    { meta.type = "symlink";
      file = "/etc/runit/3";
      target = pkgs.writeScript "runit-3" "#!${pkgs.bash}/bin/bash";
    }
    { meta.type = "symlink";
      file = "/etc/runit/2";
      target = pkgs.writeScript "runit-2" ''
        #!${pkgs.bash}/bin/bash

        ${pkgs.coreutils}/bin/mkdir -p /run/runit

        exec ${pkgs.coreutils}/bin/env PATH=${pkgs.runit}/bin \
             ${pkgs.runit}/bin/runsvdir -P ${services-dir}
      '';
    }
  ];
}
