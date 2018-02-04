{ pkgs, top }:

{
  init ? top.init.runit {},
  users ? top.users.unix {},
}:

services:

assert !(services ? "files");
assert !(services ? "init");
assert !(services ? "users");

services // {
  files = top.files {};

  inherit init users;
}
