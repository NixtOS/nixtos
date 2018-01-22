{ pkgs }:

/*
 * This file defines the service solver for NixtOS.
 *
 * TODO: document it
 */

{ kernel, services }:

assert !(services ? "kernel");

let
  all-extenders = builtins.concatLists (
    pkgs.lib.mapAttrsToList (service: extenders:
      extenders (extenders-for service)
    ) services
  );

  extenders-for = service:
    map (e: e.data) (
      builtins.filter (e: e.extends == service) all-extenders
    );

  extenders-for-assert-type = service: type:
    map (e: assert e.type == type; e) (extenders-for service);
in
{
  inherit extenders-for extenders-for-assert-type;
}
