{ pkgs, nixtos, testbed }:

let
  make-attrset = nixtos.lib.make-attrset;
  nv = name: value: { inherit name value; };
in
testbed.run {
  correct-set = {
    expr = make-attrset (_: "error") [ (nv "foo" 1) (nv "bar" 2) ];
    expected = { foo = 1; bar = 2; };
  };

  incorrect-set = {
    expr = make-attrset (_: "error") [ (nv "foo" 1) (nv "foo" 1) ];
    expected = "error";
  };

  incorrect-set-bis = {
    expr = make-attrset (_: "error") [ (nv "foo" 1) (nv "foo" 2) ];
    expected = "error";
  };
}
