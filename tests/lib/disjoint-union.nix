{ pkgs, nixtos, testbed }:

let
  disjoint-union = nixtos.lib.disjoint-union;
in
testbed.run {
  disjoint-sets = {
    expr = disjoint-union (_: "error") { foo = 1; } { bar = 1; };
    expected = { foo = 1; bar = 1; };
  };

  non-disjoint-sets = {
    expr = disjoint-union (_: "error") { foo = 1; } { foo = 1; bar = 1; };
    expected = "error";
  };
}
