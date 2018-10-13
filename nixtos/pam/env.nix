{ pkgs, top }:

{
  assertions ? "assertions",
  pam ? "pam",
  vars,
} @ args:

extenders: # Ignored

{
  ${assertions} = with top.lib.types;
    assert-type "nixtos.pam.env's argument" args (product-opt {
      req = {
        vars = attrs string;
      };
      opt = {
        assertions = string;
        pam = string;
      };
    });

  ${pam} = pkgs.lib.mapAttrsToList (name: value: {
    meta.type = "env";
    inherit name value;
  }) vars;
}
