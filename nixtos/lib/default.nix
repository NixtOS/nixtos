{ pkgs, top }:

rec {
  # Returns the sorted dependencies of a list of elements.
  #
  # `depends a b` should return true iff `a` depends on `b`
  # `graph` is a list that contains all the nodes in the graph
  # `elements` is a list of nodes for which we're looking for dependencies
  #
  # TODO: this implementation is horribly slow, but it works. Putting some real
  # thought in the algorithm could be a good idea, though.
  sorted-deps-of = depends: nodes: elements:
    pkgs.lib.unique (non-unique-sorted-deps-of depends nodes elements);

  non-unique-sorted-deps-of = depends: nodes: elements:
    let
      direct-deps = pkgs.lib.flatten (map (e:
        builtins.filter (x: depends e x) nodes
      ) elements);

      recursive-deps = sorted-deps-of depends nodes direct-deps;
    in
      if elements == [] then []
      else recursive-deps ++ elements;
}
