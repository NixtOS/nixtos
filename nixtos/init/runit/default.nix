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
      target = pkgs.writeScript "runit-1" ''
        Hello world from runit initialization script
      '';
    };
  }

  # TODO: actually use the extenders list to generate services
]
