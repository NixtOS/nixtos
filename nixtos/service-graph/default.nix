{ pkgs, top }:
{ name ? "service-graph", solved-services }:

let
  s = solved-services;
  services = builtins.attrNames s.all-extenders;
in
pkgs.writeTextFile {
  name = "${name}.dot";
  text = ''
    digraph "${name}" { ${
      builtins.concatStringsSep "" (map (to:
        builtins.concatStringsSep "" (map (e: ''
          "${e.meta.source}" -> "${to}";
        '') (s.extenders-for to))
      ) services)
    } }
  '';
}
