{ pkgs, top }:

{
  files ? top.files {},
  init ? top.init.runit {},
  users ? top.users.unix {},
}:

services:

assert !(services ? "files");
assert !(services ? "init");
assert !(services ? "users");

services // {
  inherit files init users;
}
