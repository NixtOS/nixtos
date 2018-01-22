{ pkgs }:

{ activation-scripts ? "activation-scripts" }:

extenders:

[
  { extends = activation-scripts;
    data =
      assert builtins.all (e:
        1 == pkgs.lib.count (x: x.file == e.file) extenders
      ) extenders;
      {
        type = "script";
        script = pkgs.lib.concatStringsSep "\n" (map (e:
          ''mkdir -p "${baseNameOf e.file}"'' + "\n" + (
            if e.type == "symlink" then
              ''ln -s "${e.target}" "${e.file}"''
            else
              throw "Unknown type for generating file: ‘${e.type}’"
          )
        ) extenders);
      };
  }
]
