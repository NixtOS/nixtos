{ pkgs, top }:

{ size, persist, name, type ? "qcow2" }:

{ store }:

let
  build-cmd = "${pkgs.kvm}/bin/qemu-img create -f ${type} ${name} ${size}";
in
{
  build =
    if persist then ''
      if [ ! -f "${name}" ]; then
        ${build-cmd}
      fi
    '' else ''
      rm -i "${name}"
      ${build-cmd}
    '';

  options = ''
    -drive file="${name}",if=virtio
  '';
}
