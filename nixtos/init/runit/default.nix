{ pkgs }:

{
  kernel ? "kernel",
  files ? "files",
}:

extenders: [
  { extends = kernel;
    data = {
      type = "init";
      command = "${pkgs.runit}/bin/runit";
    };
  }

  { extends = files;
    data = {
      type = "symlink";
      file = "/etc/runit/1";
      target = pkgs.writeScript "runit-1" "#!${pkgs.bash}/bin/bash";
    };
  }

  { extends = files;
    data = {
      type = "symlink";
      file = "/etc/runit/3";
      target = pkgs.writeScript "runit-3" "#!${pkgs.bash}/bin/bash";
    };
  }

  # TODO: actually use the extenders list to generate services
]
