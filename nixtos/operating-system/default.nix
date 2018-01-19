{ pkgs }:
{
  kernel ? pkgs.linuxPackages.kernel,
}:

let
  mkInitrd = import ../make-initrd { inherit pkgs; };

  # TODO: add nixtos version here
  version = "nixtos-${pkgs.lib.nixpkgsVersion}";

  initScript = pkgs.writeScript "init" ''
    #!${pkgs.busybox}/bin/busybox sh

    echo "It works!"

    while true; do
      sleep 1
    done
  '';

  initrd = pkgs.makeInitrd {
    contents = [
      { object = initScript;
        symlink = "/init";
      }
    ];
  };
in
pkgs.runCommand version {} ''
  mkdir $out
  ln -s ${kernel}/bzImage $out/kernel
  ln -s ${initrd}/initrd $out/initrd
''
