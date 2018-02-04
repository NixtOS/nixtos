{ pkgs, top }:

{
  make-initrd = import ./make-initrd { inherit pkgs top; };
  solve-block-devices = import ./solve-block-devices { inherit pkgs top; };
  solve-filesystems = import ./solve-filesystems { inherit pkgs top; };
  solve-services = import ./solve-services { inherit pkgs top; };

  # Returns the sorted dependencies of a list of elements.
  #
  # `depends a b` should return true iff `a` depends on `b`
  # `graph` is a list that contains all the nodes in the graph
  # `elements` is a list of nodes for which we're looking for dependencies
  sorted-deps-of = depends: nodes: elements:
    let
      impl = visited: element:
        let deps = builtins.filter (x: depends element x) nodes; in
        if builtins.elem element visited then []
        else if deps == [] then [element]
        else impl-for-all visited deps ++ [element];
      impl-for-all = visited: elts:
        builtins.foldl' (acc: elt: acc ++ impl (visited ++ acc) elt) [] elts;
    in
      impl-for-all [] elements;
}
