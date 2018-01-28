{ pkgs, top }:

{ persist, name, script }:

{ store }:

let
  script-file = pkgs.writeText "guestfish-script" script;
  build-cmd = "${pkgs.libguestfs}/bin/guestfish < ${script-file}";
in
{
  build =
    if persist then ''
      if [ ! -f '${name}' ]; then
        ${build-cmd}
      fi
    '' else ''
      rm -i '${name}'
      ${build-cmd}
    '';

  options = "-drive file='${name}',if=virtio";
}
