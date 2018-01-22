{ pkgs }:

{ kernel ? "kernel" }:

extenders: [
  { extends = "kernel";
    data = {
      type = "init";
      command = "${pkgs.runit}/bin/runit";
    };
  }

  # TODO: actually use the extenders list to generate services
]
