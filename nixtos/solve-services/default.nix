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
      extenders (
        map (e: e.data)
            (pkgs.lib.filter (e: e.extends == service) all-extenders)
      )
    ) services
  );

  kernel-extenders = builtins.filter (e: e.extends == "kernel") all-extenders;
  kernel-extender = assert builtins.length kernel-extenders == 1;
                    let res = builtins.head kernel-extenders; in
                    assert res.data.type == "init";
                    res.data;
in
{
  init-command = kernel-extender.command;
}
