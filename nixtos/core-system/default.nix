{ pkgs, top }:

{
  files ? top.files {},
  init ? top.init.runit {},
  users ? top.users.unix {},
  groups ? top.groups.unix {},
}:

services:

assert !(services ? "files");
assert !(services ? "init");
assert !(services ? "users");
assert !(services ? "groups");

services // {
  inherit files init users groups;
}
