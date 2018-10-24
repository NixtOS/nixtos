{ pkgs, top }:

{
  assertions ? "assertions",
  activation-scripts ? "activation-scripts",
} @ args:

extenders:

let
  # TODO(medium): make upgrades more atomic by doing like /etc/static
  files = top.lib.make-attrset (f:
    throw "Trying to define the same files at multiple positions: ${builtins.toJSON f}"
  ) (map (e: { name = e.file; value = e; }) extenders);
in
{
  ${assertions} = with top.lib.types;
    assert-type "nixtos.files's argument" args (product-opt {
      req = {};
      opt = {
        assertions = string;
        activation-scripts = string;
      };
    });

  ${activation-scripts} = {
    meta.type = "script";
    script = pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (file: d:
      ''mkdir -p "${dirOf file}"'' + "\n" + (
        if d.meta.type == "symlink" then
          ''ln -s "${d.target}" "${file}"''
        else
          throw "Unknown type for generating file ‘${file}’: ‘${d.type}’"
      )
    ) files);
  };
}
