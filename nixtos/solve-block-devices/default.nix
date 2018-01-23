{ pkgs, top }:

block-devices:

# TODO: run a topological sort so that mounting avoids useless operations?

let
  if-needed-for = indent: block-device: commands: ''
    ${indent}if [ ! -b "${block-device}" ]; then
    ${indent}  echo "Building ${block-device}"
    ${commands "${indent}  "}
    ${indent}fi
  '';

  build = indent: bd-name:
    let block-device = block-devices.${bd-name}; in
    if-needed-for indent bd-name (indent:
      pkgs.lib.concatStringsSep "\n" (map (dep:
        build-and-wait-for indent block-devices.${dep}
      ) block-device.depends-on) + "\n" +
      indent + block-device.build-command bd-name
    );

  build-and-wait-for = indent: block-device:
    build indent block-device + ''
      while [ ! -b ${block-device} ]; do
        sleep 0
      done
    '';
in
{
  build = build "";
  build-and-wait-for = build-and-wait-for "";
}
