{ pkgs, nixtos }:

let
  disjoint-union-tests = [
    { a = { foo = 1; };
      b = { bar = 1; };
      res = { foo = 1; bar = 1; };
    }
    { a = { foo = 1; };
      b = { bar = 1; foo = 1; };
      res = "an error";
    }
  ];
  disjoint-union-result =
    builtins.foldl' (acc: x:
      let res = nixtos.lib.disjoint-union (_: "an error") x.a x.b; in
      if res == x.res then acc
      else throw "disjoint-union (…) ${builtins.toJSON x.a} ${builtins.toJSON
      x.b} = ${builtins.toJSON res} when ${builtins.toJSON x.res} was expected"
    ) true disjoint-union-tests;

  make-attrsets-tests = [
    { l = [ { name = "foo"; value = 1; } { name = "bar"; value = 2; } ];
      res = { foo = 1; bar = 2; };
    }
    { l = [ { name = "foo"; value = 1; } { name = "foo"; value = 1; } ];
      res = "an error";
    }
  ];
  make-attrsets-result =
    builtins.foldl' (acc: x:
      let res = nixtos.lib.make-attrset (_: "an error") x.l; in
      if res == x.res then acc
      else throw "make-attrset (…) ${builtins.toJSON x.l} = ${builtins.toJSON
      res} when ${builtins.toJSON x.res} was expected"
    ) true make-attrsets-tests;

  # Types used here:
  #   test = { expr, expected }
  #   test-result = { name, expected, result } WHERE expected != result
  testbed = {
    # map string test -> list test-result
    run = tests:
      builtins.map (name: {
        inherit name;
        expected = tests.${name}.expected;
        result = tests.${name}.expr;
      }) (builtins.filter (name:
        tests.${name}.expr != tests.${name}.expected
      ) (builtins.attrNames tests));

    # map string ({ ... } -> list test-result) -> list test-result
    recurse = tests:
      builtins.concatLists (
        builtins.map (name:
          builtins.map (test-result: {
            inherit (test-result) expected result;
            name = "${name}.${test-result.name}";
          }) (tests.${name} { inherit pkgs nixtos testbed; })
        ) (builtins.attrNames tests)
      );
  };
in
  testbed.recurse {
    sorted-deps-of = import ./sorted-deps-of.nix;
  }
  # TODO(high): disjoint-union-result && make-attrsets-result;
