{ pkgs, top }:

{
  kernel ? "kernel",
  files ? "files",
}:

extenders:

let
  services-dir =
    assert builtins.all (e:
      1 == pkgs.lib.count (x: x.name == e.name) extenders
    ) extenders;
    pkgs.runCommand "runit-services" {} (
      ''
        mkdir $out
      '' + pkgs.lib.concatStringsSep "\n" (
        map (ext:
          assert ext.type == "service"; ''
            mkdir "$out/${ext.name}"

            ln -s "/run/runit/supervise-${ext.name}" \
                  "$out/${ext.name}/supervise"

            cat > "$out/${ext.name}/run" <<EOF
            #!${pkgs.bash}/bin/bash

            exec ${pkgs.writeScript "runit-init-${ext.name}" ext.script}
            EOF

            chmod +x "$out/${ext.name}/run"
          ''
        ) extenders
      )
    );
in
[
  { extends = kernel;
    data = {
      type = "init";
      command = "${pkgs.runit}/bin/runit";
    };
  }

  { extends = files;
    data = {
      type = "symlink";
      file = "/etc/runit/1";
      target = pkgs.writeScript "runit-1" "#!${pkgs.bash}/bin/bash";
    };
  }

  { extends = files;
    data = {
      type = "symlink";
      file = "/etc/runit/3";
      target = pkgs.writeScript "runit-3" "#!${pkgs.bash}/bin/bash";
    };
  }

  { extends = files;
    data = {
      type = "symlink";
      file = "/etc/runit/2";
      target = pkgs.writeScript "runit-2" ''
        #!${pkgs.bash}/bin/bash

        ${pkgs.coreutils}/bin/mkdir -p /run/runit

        exec ${pkgs.coreutils}/bin/env PATH=${pkgs.runit}/bin \
             ${pkgs.runit}/bin/runsvdir -P ${services-dir}
      '';
    };
  }
]
