{ pkgs, nixtos, testbed }:

with nixtos.lib.merges;
testbed.run {
  const-hello = {
    expr = const "hello" [];
    expected = {
      result = "hello";
      errors = [];
    };
  };
  const-does-ignore = {
    expr = const "hello" [ "world" ];
    expected = {
      result = "hello";
      errors = [];
    };
  };

  attrs-disjoint-union-pass = {
    expr = attrs.disjoint-union [
      { foo = 1; bar = 2; }
      { baz = 3; quux = "hello"; }
    ];
    expected = {
      result = { foo = 1; bar = 2; baz = 3; quux = "hello"; };
      errors = [];
    };
  };
  attrs-disjoint-union-fail = {
    expr = attrs.disjoint-union [
      { foo = 1; bar = 2; baz = 3; }
      { foo = 1; bar = 5; quux = "hello"; }
    ];
    expected = {
      errors = [ {
        path = [];
        error =
          "keys passed multiple times to disjoint union: [ \"bar\" \"foo\" ]";
      } ];
    };
  };

  product-of-const = {
    expr = product { a = const "hello"; b = const "world"; } [];
    expected = {
      result = { a = "hello"; b = "world"; };
      errors = [];
    };
  };
  product-const-disjoint-union = {
    expr = product { a = const "hello"; b = attrs.disjoint-union; } [
      { a = "world"; b = { foo = 1; }; }
      { a = 42; b = { bar = 0.1337; }; }
    ];
    expected = {
      result = { a = "hello"; b = { foo = 1; bar = 0.1337; }; };
      errors = [];
    };
  };
  product-const-disjoint-union-fail = {
    expr = product { a = const "hello"; b = attrs.disjoint-union; } [
      { a = "world"; b = { foo = 1; }; }
      { a = 42; b = { foo = 0.1337; }; }
    ];
    expected = {
      errors = [ {
        path = [ "b" ];
        error = "keys passed multiple times to disjoint union: [ \"foo\" ]";
      } ];
    };
  };
  product-double-fail = {
    expr = product { a = attrs.disjoint-union; b = attrs.disjoint-union; } [
      { a = { foo = 0.1337; }; b = { foo = 1; }; }
      { a = { foo = 1; }; b = { foo = 0.1337; }; }
    ];
    expected = {
      errors = [ {
        path = [ "a" ];
        error = "keys passed multiple times to disjoint union: [ \"foo\" ]";
      } {
        path = [ "b" ];
        error = "keys passed multiple times to disjoint union: [ \"foo\" ]";
      } ];
    };
  };
}
