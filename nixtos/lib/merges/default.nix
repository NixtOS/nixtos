{ pkgs, top }:

# A merge function is list T -> { result = T'; errors = list error; }
let
  # Merge function that ignores its arguments and just returns `value`
  const = value: l: {
    result = value;
    errors = [];
  };

  # Merge attrsets by disjoint union
  attrs-disjoint-union = l:
    let
      # Either a set, if the disjoint-union passed, or a list, if the sets
      # weren't actually disjoint
      union = builtins.foldl' (top.lib.disjoint-union (e: e)) {} l;
    in
    if builtins.isList union then {
      errors = [ {
        path = [];
        error = "keys passed multiple times to disjoint union: " +
                pkgs.lib.generators.toPretty {} union;
      } ];
    } else {
      result = union;
      errors = [];
    };

  # Merge attrsets under each key according to provided policies
  product = submergers: l:
    let
      folded-attrs = pkgs.lib.foldAttrs (n: a: [n] ++ a) [] l;
      outcome = pkgs.lib.mapAttrs (n: submerger:
        submerger (folded-attrs.${n} or [])
      ) submergers;
      result = pkgs.lib.mapAttrs (n: v: v.result) outcome;
      errors = builtins.concatLists (builtins.map (n:
        builtins.map (e: e // { path = [n] ++ e.path; }) outcome.${n}.errors
      ) (builtins.attrNames result));
    in
      if errors != [] then { inherit errors; }
      else { inherit result errors; };
in
{
  merge = name: merger: value:
    let
      merged = merger value;
      res = merged.result;
      assertions = builtins.map (e: {
        meta.type = "assertion-failure";
        message =
          builtins.concatStringsSep "." ([name] ++ e.path) + ": " + e.error;
      }) merged.errors;
    in
    if assertions != [] then { inherit assertions; }
    else { inherit res assertions; };

  inherit const product;

  attrs = {
    disjoint-union = attrs-disjoint-union;
  };
}
