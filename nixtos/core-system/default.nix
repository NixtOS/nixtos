{ pkgs, top }:

{ init ? top.init.runit {} }:

services:

assert !(services ? "files");
assert !(services ? "init");

services // {
  files = top.files {};

  inherit init;
}
