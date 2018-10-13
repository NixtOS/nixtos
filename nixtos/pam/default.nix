{ pkgs, top }:

{
  __functor = self: import ./service.nix { inherit pkgs top; };
  env = import ./env.nix { inherit pkgs top; };
}
