{ pkgs }:
{
  kernel ? pkgs.linuxPackages.kernel,
}:

let
  mkInitrd = import ../make-initrd { inherit pkgs; };

  # TODO: add nixtos version here
  version = "nixtos-${pkgs.lib.nixpkgsVersion}";

  initScript = pkgs.writeText "init" ''
    #!${pkgs.busybox} sh

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
  ln -s ${kernel} $out/kernel
  ln -s ${initrd} $out/initrd
''
