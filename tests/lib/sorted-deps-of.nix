{ pkgs, nixtos, testbed }:

let
  deps = a: b: builtins.elem b.id a.deps;
  graph = [
    { id = 0; deps = []; }
    { id = 1; deps = [0]; }
    { id = 2; deps = []; }
    { id = 3; deps = [2 1]; }
    { id = 4; deps = [6]; }
    { id = 5; deps = [2 3]; }
    { id = 6; deps = [2 3 5]; }
    { id = 7; deps = [2]; }
    { id = 8; deps = [9]; }
    { id = 9; deps = [10]; }
    { id = 10; deps = [11]; }
    { id = 11; deps = [13]; }
    { id = 12; deps = [14]; }
    { id = 13; deps = [12]; }
    { id = 14; deps = [15]; }
    { id = 15; deps = []; }
  ];
  tests = [
    { begin = [0]; result = [0]; }
    { begin = [1]; result = [0 1]; }
    { begin = [2]; result = [2]; }
    { begin = [1 2]; result = [0 1 2]; }
    { begin = [10]; result = [15 14 12 13 11 10]; }
    { begin = [6 3]; result = [2 0 1 3 5 6]; }
  ];
in
testbed.run (
  builtins.listToAttrs (
    pkgs.lib.imap1 (i: t: {
      name = "test${toString i}";
      value = {
        expr =
          let
            start-nodes = map (builtins.elemAt graph) t.begin;
            end-nodes = nixtos.lib.sorted-deps-of deps graph start-nodes;
          in
            map (n: n.id) end-nodes;
        expected = t.result;
      };
    }) tests
  )
)
